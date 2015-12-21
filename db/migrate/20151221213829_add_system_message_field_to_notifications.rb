class AddSystemMessageFieldToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_system_message, :boolean, default: false
  end
end
