class AddExpiresAtToUserDocuments < ActiveRecord::Migration
  def change
    add_column :user_documents, :expires_at, :date
  end
end
