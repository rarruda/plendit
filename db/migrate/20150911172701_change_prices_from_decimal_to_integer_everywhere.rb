class ChangePricesFromDecimalToIntegerEverywhere < ActiveRecord::Migration
  def change
    change_column :ads,           :price,  :integer
    change_column :bookings,      :amount, :integer
    change_column :booking_items, :amount, :integer
  end
end
