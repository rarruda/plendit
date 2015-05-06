class CreateAdImages < ActiveRecord::Migration
  def change
    create_table :ad_images do |t|
      t.references :ad, index: true, foreign_key: true
      t.string :description

      t.timestamps null: false
    end
  end
end
