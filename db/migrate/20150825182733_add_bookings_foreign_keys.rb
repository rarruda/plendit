class AddBookingsForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :bookings, :users, column: :from_user_id
    add_foreign_key :bookings, :ad_items
  end
end
