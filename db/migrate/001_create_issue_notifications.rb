class CreateIssueNotifications < ActiveRecord::Migration
  def self.up
    create_table :issue_notifications do |t|
      t.date :notif_start_date
      t.date :notif_end_date
      t.string :repeat_interval
      t.integer :issue_id, :default => 0, :null => false
    end

    add_index 'issue_notifications', ['issue_id'], :name => "issue_notifications_issue_id"
  end

  def self.down
    drop_table :issue_notifications
  end
end
