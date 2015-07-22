class RenameBookingToFromToStartEndsAtColumnsInBookings < ActiveRecord::Migration
  def change
    rename_column :bookings, :booking_from, :starts_at
    rename_column :bookings, :booking_to,   :ends_at
  end
end
