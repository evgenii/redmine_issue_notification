module Plugin
  module IssueNotification

    module IssuesController
      module InstanceMethods
        #Add a before_filter method to IssuesController
        def find_notifications
          @notifications = @issue.issue_notifications   
        end      
      end

      def self.included(receiver)
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          unloadable
          helper :notifications
          include NotificationsHelper
          #Register the before_filter method  
          before_filter :find_notifications , :only => [:show]
        end
      end
    end

    module Issue
      
      module InstanceMethods
        #Returns an array with all the emails of the people involved in 
        #the issue
        #Watchers, Issue creator, Assignee(s)
        def get_emails
          receivers  = watchers.collect{ |i| i.user.mail }
          receivers << author.mail
          if   assigned_to.is_a?(User)
          #Assigned to a user
            receivers << assigned_to.mail
          elsif assigned_to.is_a?(Group)
          #Issue is assigned to a group (Redmine 1.3.0)     
            receivers << assigned_to.users.collect(&:mail)
          end
          receivers   
        end   
      end

      def self.included(receiver)
        receiver.send :include, InstanceMethods 
        receiver.class_eval do
          unloadable
          #Add has_many relation to notifications  
          has_many :issue_notifications, :dependent => :destroy
        end
      end
    end

  end
end     
