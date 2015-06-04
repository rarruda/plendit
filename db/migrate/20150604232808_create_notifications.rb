class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :notification_status_id
      t.references :notifiable, polymorphic: true, index: true
      t.string :message

      t.timestamps null: false
    end
  end
end
