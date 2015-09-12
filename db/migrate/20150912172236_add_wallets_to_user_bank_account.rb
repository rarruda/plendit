class AddWalletsToUserBankAccount < ActiveRecord::Migration
  def change
    add_column :user_bank_accounts, :payin_wallet_vid,  :string
    add_column :user_bank_accounts, :payout_wallet_vid, :string
  end
end
