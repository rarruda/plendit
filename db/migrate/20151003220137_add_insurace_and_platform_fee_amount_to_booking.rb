class AddInsuraceAndPlatformFeeAmountToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :platform_fee_amount, :integer, :default => 0
    add_column :bookings, :insurance_amount, :integer, :default => 0
  end
end
