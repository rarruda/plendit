class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :phome_number, limit: 8
      t.datetime :join_timestamp
      t.datetime :last_action_timestamp
      t.string :private_link_to_facebook
      t.string :private_link_to_linkedin
      t.integer :ephemeral_answer_percent

      t.timestamps null: false
    end
  end
end
