class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :image_url
      t.string :profile_url

      t.timestamps null: false
    end
    add_index :identities, :uid
  end
end
