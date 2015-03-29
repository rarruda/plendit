class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :booking_id
      t.integer :from_profile_id
      t.integer :to_profile_id
      t.text :content

      t.timestamps null: false
    end
    add_index :messages, :booking_id
    add_index :messages, :from_profile_id
    add_index :messages, :to_profile_id
  end
end
