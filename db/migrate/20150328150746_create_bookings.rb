class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :ad_item_id
      t.integer :from_profile_id
      t.integer :booking_status_id
      t.decimal :price, :precision => 10, :scale => 2
      t.datetime :booking_from
      t.datetime :booking_to
      t.datetime :first_reply_at

      t.timestamps null: false
    end
    add_index :bookings, :ad_item_id
    add_index :bookings, :from_profile_id
    add_index :bookings, :booking_status_id
  end
end
