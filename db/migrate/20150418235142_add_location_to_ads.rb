class AddLocationToAds < ActiveRecord::Migration
  def change
    add_reference :ads, :location, index: true, foreign_key: true
  end
end
