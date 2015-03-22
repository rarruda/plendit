class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.integer :profile_id, index: true
      t.string :title
      t.string :short_description
      t.text :body
      t.decimal :price, :precision => 10, :scale => 2
      t.text :tags

      t.timestamps null: false
    end
  end
end
