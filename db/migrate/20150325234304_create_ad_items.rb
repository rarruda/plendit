class CreateAdItems < ActiveRecord::Migration
  def change
    create_table :ad_items do |t|
      t.integer :ad_id

      t.timestamps null: false
    end
    add_index :ad_items, :ad_id
  end
end
