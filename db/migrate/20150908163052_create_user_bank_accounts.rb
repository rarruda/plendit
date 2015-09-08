class CreateUserBankAccounts < ActiveRecord::Migration
  def change
    create_table :user_bank_accounts do |t|
      t.references :user, index: true, foreign_key: true
      t.string :account_number
      t.string :iban

      t.timestamps null: false
    end
  end
end
