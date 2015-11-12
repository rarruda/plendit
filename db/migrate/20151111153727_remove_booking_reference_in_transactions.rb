class RemoveBookingReferenceInTransactions < ActiveRecord::Migration
  def change
    remove_reference :transactions, :booking
  end
end
