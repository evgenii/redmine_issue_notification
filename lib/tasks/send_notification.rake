namespace :issue_notification do
   
  ### Helper methods ### 

  #Checks to see if there are any due notifications for
  #an issue, and then sends the emails
  def send_notifications(issue)
  
    Rails.logger.info "[Sending notifications for #{issue.to_s}]"
    notifications = issue.issue_notifications.select{ 
                   |nt| !nt.notif_start_date.nil? and nt.notif_start_date <= Date.today }  

    notifications.each do |nt|         
      if nt.is_due?
        Rails.logger.info "[Sending notification #{nt.inspect}]"
        unless issue.due_date.nil? 
          days = (issue.due_date.to_date - Date.today).to_i
          str_days_left = days <= 0 ? "0" : days.to_s
        else
          str_days_left = "-"
        end 
        NotificationMailer.deliver_notification_reminder(issue.watchers, issue, str_days_left )
      end
    end       
  end

  ### Rake Tasks ###

  desc "Clean up any invalid notifications"
  task :clean_invalid_notifications => :environment do
    IssueNotification.clean_invalid_notifications
  end

  desc "Clean up any expired notifications"
  task :clean_expired_notifications => :environment do
    IssueNotification.clean_expired_notifications
  end

  desc "Check issues and send notification messages"
  task :send => [:clean_expired_notifications ] do

    Rails.logger.info "[Sending notifications]"

    #Select all issues that are not closed, have a done ratio under 100,
    #and have notifications associated with them
    @issues = Issue.all.select{ |is| is.issue_notifications.present? and
                                 is.done_ratio < 100 and !is.closed? }

    @issues.each { |issue| send_notifications(issue) }

    Rails.logger.info "[Finished sending notifications]"
  end
  
end

