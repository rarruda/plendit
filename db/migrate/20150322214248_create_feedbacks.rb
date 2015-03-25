class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :ad_id
      t.integer :from_profile_id
      t.integer :score
      t.text :body

      t.timestamps null: false
    end
    add_index :feedbacks, :ad_id
    add_index :feedbacks, :from_profile_id
  end
end
