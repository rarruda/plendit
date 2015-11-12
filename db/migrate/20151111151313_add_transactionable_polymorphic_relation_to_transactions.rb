class AddTransactionablePolymorphicRelationToTransactions < ActiveRecord::Migration
  def change
    add_reference :transactions, :transactionable, polymorphic: true, index: true, index: { name: 'index_transactions_on_transactionable_type_and_id' }
  end
end
