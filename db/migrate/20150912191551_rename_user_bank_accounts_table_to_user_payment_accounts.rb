class RenameUserBankAccountsTableToUserPaymentAccounts < ActiveRecord::Migration
  def change
    rename_table :user_bank_accounts, :user_payment_accounts
  end
end
