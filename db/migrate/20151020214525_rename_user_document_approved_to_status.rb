class RenameUserDocumentApprovedToStatus < ActiveRecord::Migration
  def change
    rename_column :user_documents, :approved, :status
    change_column :user_documents, :status, 'integer USING CAST(status AS integer)'
  end
end
