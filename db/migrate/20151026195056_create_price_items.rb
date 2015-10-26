class CreatePriceItems < ActiveRecord::Migration
  def change
    create_table :price_items do |t|
      t.references :price, index: true, foreign_key: true
      t.integer :unit
      t.integer :amount
      t.integer :effective_from_unit

      t.timestamps null: false
    end
  end
end
