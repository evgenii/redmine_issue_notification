class NotificationsController < ApplicationController
  unloadable

  verify :method => :delete, :only => :destroy, 
                    :render => {:nothing => true, :status => :method_not_allowed}
  before_filter :find_issue, :find_project_from_association
 
  #Creates a new Issue Notification
  def new
    #Exception block
    begin  

      #Create a notification object and populate it with the context attributes
      @notification = @issue.issue_notifications.build

      #Shorthand for accessing the parameters
      start_date_type = params[:start_date_type]
      end_date_type   = params[:end_date_type]
      repeat_periods  = params[:repeat_periods]
      repeat_interval = params[:repeat_intervals]  
      nr_days_before = Integer( params[:notification_days_before])

      #Number parameters should be positive
      raise ArgumentError if nr_days_before < 0

      @notification.notif_start_date = case start_date_type
        when "date"        then params[:notification_start_date]
        when "days_before" then @issue.due_date - nr_days_before.days
        else nil
      end

      if params[:repeat_notification].eql?('Yes') 

      #1/2/3/4 => Repeat every 1 D, 2 W, 3 M, 4 Y
      @notification.repeat_interval=case repeat_periods
        when "Daily"   then  "#{repeat_interval}/0/0/0"
        when "Weekly"  then  "0/#{repeat_interval}/0/0"
        when "Monthly" then  "0/0/#{repeat_interval}/0"
        when "Yearly"  then  "0/0/0/#{repeat_interval}"
        else nil
      end 
        
      if params[:end_notification].eql?('Yes') 
        #If the end of the notification is given either as a date, or 
        #as a number of events until it expires
        if params[:end_date_type].eql?('expire')
          nr_repeats     = Integer( params[:notification_events_until_expire] )
          raise ArgumentError if nr_repeats <= 0 
        end 
        @notification.notif_end_date = case end_date_type
          when "date"   then Date.parse(params[:notification_end_date])
          when "expire" then IssueNotification.calc_end_date(
                               @notification.notif_start_date, 
                               @notification.repeat_interval, nr_repeats )
          else nil      #notification never expires
        end
     
      end 

    else #Do not repeat the notification (single event)
      @notification.notif_end_date = @notification.notif_start_date
    end

    @notification.save if request.post?
 
   rescue ArgumentError 
     #Set error messages ,then continue
     @notification.errors.add(:invalid_value, "")
   end 

    @issue.reload
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js do
        @notifications = @issue.issue_notifications.select{|nt| nt.valid? }
        #TODO Remove view code from controller
        render :update do |page|
          page.replace_html "notifications", :partial => 'notifications/issue_notifications'
        end
      end
    end

  end

  #Destroys an IssueNotification
  def destroy      
      @notification = IssueNotification.find params[:id]
      @notification.destroy 
      @issue.reload

      respond_to do |format|
        format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
        format.js {
          @notifications = @issue.issue_notifications.select{|nt| nt.valid? }
          render(:update) {|page| page.replace_html "notifications", :partial => 'notifications/issue_notifications'}
        }
      end
  end

  private
    def find_issue
      @issue = @object = Issue.find(params[:issue_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

end
