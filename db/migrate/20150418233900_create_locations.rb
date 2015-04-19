class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :user, index: true
      t.string :address_line
      t.string :city
      t.string :state
      t.string :post_code
      t.decimal :lat, precision: 15, scale: 13
      t.decimal :lon, precision: 15, scale: 13

      t.timestamps null: false
    end
  end
end
