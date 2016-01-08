class AddDepositOfferAmountToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :deposit_offer_amount, :integer, default: 0
  end
end
