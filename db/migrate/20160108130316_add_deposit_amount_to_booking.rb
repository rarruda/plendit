class AddDepositAmountToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :deposit_amount, :integer, default: 0
  end
end
