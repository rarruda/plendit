class RenameAmountToPayoutAmountInBooking < ActiveRecord::Migration
  def change
    rename_column :bookings, :amount, :payout_amount
  end
end
