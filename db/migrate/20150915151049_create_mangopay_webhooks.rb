class CreateMangopayWebhooks < ActiveRecord::Migration
  def change
    create_table :mangopay_webhooks do |t|
      t.string :event_type_mp
      t.string :resource_type
      t.string :resource_vid
      t.string :date_mp
      t.integer :status, default: 0
      t.string :remote_ip
      t.text   :raw_data

      t.timestamps null: false
    end
  end
end
