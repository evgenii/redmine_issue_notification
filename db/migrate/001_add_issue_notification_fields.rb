class AddIssueNotificationFields < ActiveRecord::Migration
  def self.up
    add_column :issues, :send_notification,    :boolean, :default => false, :null => false
    add_column :issues, :warning_notification, :integer, :default => 0,     :null => false
    add_column :issues, :on_date_notification, :date
  end
  
  def self.down
    remove_column :issues, :send_notification
    remove_column :issues, :warning_notification
    remove_column :issues, :on_date_notification
  end
end
