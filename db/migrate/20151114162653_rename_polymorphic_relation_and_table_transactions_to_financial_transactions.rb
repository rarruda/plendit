class RenamePolymorphicRelationAndTableTransactionsToFinancialTransactions < ActiveRecord::Migration
  def change
    rename_table  :transactions, :financial_transactions
    rename_column :financial_transactions, :transactionable_id,   :financial_transactionable_id
    rename_column :financial_transactions, :transactionable_type, :financial_transactionable_type
  end
end
