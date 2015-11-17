class RemoveInsuredFromBookings < ActiveRecord::Migration
  def change
    remove_column :bookings, :insured, :boolean
  end
end
