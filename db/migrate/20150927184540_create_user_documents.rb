class CreateUserDocuments < ActiveRecord::Migration
  def change
    create_table :user_documents do |t|
      t.references :user, index: true, foreign_key: true
      t.string :guid, limit: 36, index: true
      t.integer :category
      t.boolean :approved
      t.attachment :document

      t.timestamps null: false
    end
  end
end
