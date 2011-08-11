require 'redmine'
require 'dispatcher'

#Add patches to models
Dispatcher.to_prepare do
  require_dependency 'issue'
  require 'redmine_issue_notifications/patch_redmine_classes'
  Issue.send(:include, ::Plugin::IssueNotification::Issue)
  IssuesController.send(:include, ::Plugin::IssueNotification::IssuesController)
end

#Hooks
require_dependency 'notification_issue_hook'

Redmine::Plugin.register :redmine_issue_notification do
  name 'Redmine Issue Notification plugin'
  author 'Evgenii.S.Semenchuk'
  description 'This plugin is send notification email (to watchers) about comming due date'
  version '0.0.1'
  url 'http://github.com/evgenii/redmine_issue_notification'
  author_url 'http://github.com/evgenii'

end





