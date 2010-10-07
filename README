# Issue notification
Issue notification is redmine plugin that send notification to watchers about due date is coming

## Install plugin
1. cd /path_to_you_app/vendor/plugins
2. git clone git://github.com/evgenii/redmine_issue_notification.git
3. cd ../../ 
4. rake db:migrate_plugins - to add columns
5. ruby script/server - to start application. Enjoy!

## Sends notification
To send notification add crontab for run rake task 'rake issue_notification:send'
Example:
> crontab -e
choose text editor, then insert code
> SHELL=/bin/bash
> 0 7 * * * cd /full/path/to/your/rails/application && rake issue_notification:send &> /tmp/cron_issue_notification.log
save it and crone will automatic starting 

To start/stop/restart cron (on debian) use:
> /etc/init.d/cron command

## Language
For now support only:
* Russian
* Ukrainian
* English

