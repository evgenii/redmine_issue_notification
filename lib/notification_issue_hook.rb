class NotificationIssueHook < Redmine::Hook::ViewListener

  ####################################################  
  # views
  ####################################################  
  
  # context: 
  #   issue - 
  #   form - 
  def view_issues_form_details_bottom( context = { } )
    # the controller parameter is part of the current params object
    # This will render the partial into a string and return it.
    context[:controller].send( :render_to_string, {
       :partial => "hooks/issue_notification_form", 
       :locals => { :issue => context[:issue], :form => context[:form] }
      })
  end
  
  # context: 
  #   issue - 
  def view_issues_show_details_bottom( context = { } )
    context[:controller].send( :render_to_string, {
       :partial => "hooks/issue_notification_show", 
       :locals => { :issue => context[:issue] }
      })
  end
  
  ####################################################  
  # controllers
  ####################################################  

  # context: 
  #   params - 
  #   issue - 
  def controller_issues_new_before_save( context = { } )
    if context[:params][:issue][:send_notification] == '1'
      context[:issue].send_notification = context[:params][:issue][:send_notification]
      context[:issue].warning_notification = context[:params][:issue][:warning_notification]
      context[:issue].on_date_notification = context[:params][:issue][:on_date_notification]
      
    else
      context[:issue].send_notification = false
      context[:issue].warning_notification = 0
      context[:issue].on_date_notification = "0000-00-00"
    end
  end
  
  # context: 
  #   params - 
  #   issue - 
  def controller_issues_edit_before_save( context={ } )
    controller_issues_new_before_save( context )
  end
  
end
