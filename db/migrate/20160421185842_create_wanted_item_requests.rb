class CreateWantedItemRequests < ActiveRecord::Migration
  def change
    create_table :wanted_item_requests do |t|
      t.string :description
      t.text :email
      t.references :user, index: true, foreign_key: true
      t.string :place

      t.timestamps null: false
    end
  end
end
