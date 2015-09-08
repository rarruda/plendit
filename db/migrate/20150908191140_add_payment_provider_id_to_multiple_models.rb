class AddPaymentProviderIdToMultipleModels < ActiveRecord::Migration
  def change
    add_column :users, :payment_provider_id, :string
    add_column :user_bank_accounts, :payment_provider_id, :string
  end
end
