class MoveWalletsFromUserPaymentAccountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :payin_wallet_vid, :string
    add_column :users, :payout_wallet_vid, :string
    execute "UPDATE users SET payin_wallet_vid  = user_payment_accounts.payin_wallet_vid  FROM user_payment_accounts WHERE  users.id = user_payment_accounts.user_id"
    execute "UPDATE users SET payout_wallet_vid = user_payment_accounts.payout_wallet_vid FROM user_payment_accounts WHERE  users.id = user_payment_accounts.user_id"
    remove_column :user_payment_accounts, :payin_wallet_vid
    remove_column :user_payment_accounts, :payout_wallet_vid
  end

  def self.down
    add_column :user_payment_accounts, :payin_wallet_vid, :string
    add_column :user_payment_accounts, :payout_wallet_vid, :string
    execute "UPDATE user_payment_accounts SET payin_wallet_vid  = users.payin_wallet_vid  FROM users WHERE  user_payment_accounts.id = users.id"
    execute "UPDATE user_payment_accounts SET payout_wallet_vid = users.payout_wallet_vid FROM users WHERE  user_payment_accounts.id = users.id"
    remove_column :users, :payin_wallet_vid
    remove_column :users, :payout_wallet_vid
  end
end
