class MakeNotificationStatusAString < ActiveRecord::Migration
  def change
    rename_column :notifications, :notification_status_id, :status
    change_column :notifications, :status, :integer, :default => 0
  end
end
