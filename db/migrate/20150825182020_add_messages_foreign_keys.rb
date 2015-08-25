class AddMessagesForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :messages, :bookings
    add_foreign_key :messages, :users, column: :from_user_id
    add_foreign_key :messages, :users, column: :to_user_id
  end
end
