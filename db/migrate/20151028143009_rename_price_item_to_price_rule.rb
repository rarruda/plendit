class RenamePriceItemToPriceRule < ActiveRecord::Migration
  def change
    remove_reference :price_items, :price
    remove_reference :ads, :price
    rename_table :price_items, :price_rules

    add_reference :price_rules, :ad, index: true, foreign_key: true
    drop_table :prices
  end
end
