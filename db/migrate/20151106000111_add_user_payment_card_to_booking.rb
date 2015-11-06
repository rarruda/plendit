class AddUserPaymentCardToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :user_payment_card, index: true, foreign_key: true
  end
end
