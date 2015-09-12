class RenameFieldsInUserBankAccount < ActiveRecord::Migration
  def change
    rename_column :user_bank_accounts, :payment_provider_id, :bank_account_vid
    rename_column :user_bank_accounts, :account_number,      :bank_account_number
    rename_column :user_bank_accounts, :iban,                :bank_account_iban
  end
end
