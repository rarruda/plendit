class DropBookingItemsTable < ActiveRecord::Migration
  def change
    drop_table :booking_items
  end
end
