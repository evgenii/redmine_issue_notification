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
      def self.included(receiver)
        receiver.class_eval do
          unloadable
          #Add has_many relation to notifications  
          has_many :issue_notifications, :dependent => :destroy
        end
      end
    end

  end
end      
