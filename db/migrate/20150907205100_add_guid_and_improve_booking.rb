class AddGuidAndImproveBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :guid, :string
    rename_column :bookings, :price, :amount
  end
end
