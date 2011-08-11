class NotificationIssueHook < Redmine::Hook::ViewListener

  ####################################################  
  # views
  ####################################################  
  
  # context: 
  #   issue - 
  def view_issues_show_description_bottom( context = { } )
    # the controller parameter is part of the current params object
    # This will render the partial into a string and return it.
    context[:controller].send( :render_to_string, {
       :partial => "hooks/issue_notification_show_description",
       :locals => { :issue => context[:issue] }
      })
  end
   
end
