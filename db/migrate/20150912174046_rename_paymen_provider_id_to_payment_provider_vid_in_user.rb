class RenamePaymenProviderIdToPaymentProviderVidInUser < ActiveRecord::Migration
  def change
    rename_column :users, :payment_provider_id, :payment_provider_vid
  end
end
