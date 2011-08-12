class IssueNotification < ActiveRecord::Base
  unloadable

  #Relations to other models
  belongs_to :issue

  #Validation
  validates_presence_of :issue
  validates_associated  :issue
  validates_presence_of :notif_start_date
  validates_format_of   :repeat_interval, :with => /[0-9]\/[0-9]\/[0-9]\/[0-9]/ ,
                        :allow_nil => true 

  def validate
    if errors.blank?
      #Validation code here    
      if notif_end_date.nil? and repeat_interval.nil?
        errors.add :notif_end_date, l(:error_end_date_repeat_null)
      end

      if !notif_start_date.nil? and !notif_end_date.nil? and
        notif_end_date < notif_start_date      
        errors.add :notif_end_date, l(:error_end_date_smaller)
      end

#     Refuse to validate when start date has expired
      if !notif_start_date.nil? and 
          notif_start_date < Date.today and repeat_interval.nil?
	  errors.add :notif_start_date, l(:error_already_expired)
      end
    end
  end

  #Helper methods

  #Provides a format for printing an exception 
  def IssueNotification.format_exception(ex_context)
    "[Exception][#{ex_context.message}|#{ex_context.backtrace}]"
  end

  #Retrieves true if the notification is a single event
  def single_notification?
    notif_start_date == notif_end_date  
  end
  
  #Returns true if the notification is not set to expire
  def never_expires?
    notif_end_date.nil? 
  end

  #Calculates the interval at which the notification is triggered
  def calc_repeat_interval_diff
    return nil if repeat_interval.blank? 
    #Grab each interval (Format : D/W/M/Y)
    intervals = repeat_interval.split('/').map{ |p| p.to_i }
    return nil if intervals.count != 4
            
    return intervals[0].days   + intervals[1].weeks + 
           intervals[2].months + intervals[3].years     
  rescue Exception => ex_context
    logger.error IssueNotification.format_exception(ex_context)
    nil
  end
  
  #Returns true if a the repeated notification triggers today
  def repeat_notification_triggered?
    #Get the date period between two consecutive triggers
    date_diff = calc_repeat_interval_diff
    notif_date = notif_start_date
    while notif_date < Date.today
      notif_date += date_diff 
    end      
    notif_date == Date.today
  rescue Exception => ex_context
    logger.error IssueNotification.format_exception(ex_context)
    false
  end
  
  #Checks if the notification is due today 
  def is_due?
    #The notification period has not started yet
    return false if notif_start_date > Date.today
 
    if single_notification?  #Single notification
      notif_start_date == Date.today 
    else                     #Repeated notification
      repeat_notification_triggered?
    end
  end

  #Class methods

  #Cleans up any expired notifications
  def self.clean_expired_notifications
    ActiveRecord::Base.transaction do
      logger.info "[Cleaning up expired notifications...]"
      IssueNotification.delete_all( ["notif_end_date < ?", Date.today])
      logger.info "[Finished cleaning up expired notifications...]"
    end
  end

  #Cleans up the invalid notifications
  #Normally, there shouldn't be any
  def self.clean_invalid_notifications
    ActiveRecord::Base.transaction do
      logger.info "[Deleting invalid notifications...]"
      @invalid_notifications = IssueNotification.all.select{ |p| !p.valid?}
      @invalid_notifications.each do |inv|
        logger.info "[Deleting notification with id = #{inv.id}]"
        issue = inv.issue  #Parent issue
        inv.destroy
        issue.reload       #Reload issue attributes after notification destroyed
      end
      logger.info "[Finished deleting invalid notifications...]"
    end
  end

  #Calculates the end date of a notification, given the start date, 
  #repeat interval, and nr of repeat events
  def self.calc_end_date(begin_date, repeat, nr_repeats)
    #Grab each interval
    intervals = repeat.split('/').map{ |p| p.to_i }
    return nil if intervals.count != 4
            
    interval_diff = intervals[0].days   + intervals[1].weeks + 
                    intervals[2].months + intervals[3].years     
    nr_repeats.times { begin_date += interval_diff }    
    begin_date  
  rescue Exception => ex_context
    logger.error IssueNotification.format_exception(ex_context)
    nil
  end

end
