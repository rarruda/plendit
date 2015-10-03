class AddInsuredToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :insured, :boolean
  end
end