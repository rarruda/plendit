class AddPurposeToFinancialTransactions < ActiveRecord::Migration
  def up
    add_column :financial_transactions, :purpose, :integer

    # purpose: rental  if transaction_type is not payout
    execute "UPDATE financial_transactions SET purpose = 1 WHERE transaction_type != 4;"

    # purpose: payout_to_user  if transaction_type is payout
    execute "UPDATE financial_transactions SET purpose = 7 WHERE transaction_type = 4;"
  end

  def down
    remove_column :financial_transactions, :purpose
  end
end
