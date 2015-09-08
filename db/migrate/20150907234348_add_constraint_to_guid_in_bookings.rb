class AddConstraintToGuidInBookings < ActiveRecord::Migration
  def change
    add_index :bookings, :guid, :unique => true
  end
end
