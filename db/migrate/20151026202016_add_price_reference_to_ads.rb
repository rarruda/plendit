class AddPriceReferenceToAds < ActiveRecord::Migration
  def change
    add_reference :ads, :price, index: true, foreign_key: true
  end
end
