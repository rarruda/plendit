class RemoveColumnPriceFromAdModel < ActiveRecord::Migration
  def change
    remove_column :ads, :price
  end
end
