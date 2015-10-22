class AddRejectionReasonToUserDocument < ActiveRecord::Migration
  def change
    add_column :user_documents, :rejection_reason, :string
  end
end
