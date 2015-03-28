class CreateBookingStatuses < ActiveRecord::Migration
  def change
    create_table :booking_statuses do |t|
      t.string :status

      t.timestamps null: false
    end
  end
end
