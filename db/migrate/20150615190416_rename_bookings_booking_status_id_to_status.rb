class RenameBookingsBookingStatusIdToStatus < ActiveRecord::Migration
  def change
    change_table :bookings do |t|
      t.rename :booking_status_id, :status
    end
    change_column :bookings, :status, :integer, :default => 0
  end
end
