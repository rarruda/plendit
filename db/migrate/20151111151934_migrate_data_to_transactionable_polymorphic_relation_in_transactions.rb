class MigrateDataToTransactionablePolymorphicRelationInTransactions < ActiveRecord::Migration
  def up
    execute "UPDATE transactions SET transactionable_id = booking_id, transactionable_type = 'Booking' WHERE transactionable_type IS NULL "
  end
  def down
    execute "UPDATE transactions SET booking_id = transactionable_id WHERE transactionable_type = 'Booking' "
  end
end
