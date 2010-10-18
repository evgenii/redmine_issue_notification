require 'redmine'

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
