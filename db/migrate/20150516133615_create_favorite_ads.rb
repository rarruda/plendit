class CreateFavoriteAds < ActiveRecord::Migration
  def change
    create_table :favorite_ads do |t|
      t.references :favorite_list, index: true, foreign_key: true
      t.references :ad, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
