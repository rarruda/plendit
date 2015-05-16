class CreateFavoriteLists < ActiveRecord::Migration
  def change
    create_table :favorite_lists do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
