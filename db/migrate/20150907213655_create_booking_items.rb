class CreateBookingItems < ActiveRecord::Migration
  def change
    create_table :booking_items do |t|
      t.references :booking, index: true, foreign_key: true
      t.integer :category
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end
