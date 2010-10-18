namespace :issue_notification do

  desc "Check issue and send notification"
  task :send => :environment do
    Issue.find_each( :conditions => [ "send_notification = true and done_ratio < ? and ( due_date > ? or on_date_notification > ? )", 100, 0, 0 ],  
      :batch_size => 100 ) do |issue|

      dates = issue.warning_notification.day.from_now.to_date
      if !issue.closed? and  
        ( ( !issue.on_date_notification.nil? and issue.on_date_notification <= dates ) or
        ( !issue.due_date.nil? and issue.due_date <= dates ) )

        issue_date = !issue.on_date_notification.nil? ? issue.on_date_notification : issue.due_date
        days = (issue_date.to_date - DateTime.now.to_date).to_i
        str_days_left = days <= 0 ? "0" : days.to_s
        NotificationMailer.deliver_notification_reminder( issue.watchers, issue, str_days_left )
      end
    end
  end

end

