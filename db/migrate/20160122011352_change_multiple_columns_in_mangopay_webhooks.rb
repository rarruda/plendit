class ChangeMultipleColumnsInMangopayWebhooks < ActiveRecord::Migration
  def change
    rename_column :mangopay_webhooks, :event_type_mp, :event_type
    rename_column :mangopay_webhooks, :date_mp,       :timestamp_v

    remove_column :mangopay_webhooks, :resource_type, :string
    add_column    :mangopay_webhooks, :resource_type, :integer
  end
end
