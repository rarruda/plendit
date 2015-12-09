class AddToUsersInFeedbacks < ActiveRecord::Migration
  def change
    add_reference :feedbacks, :to_user, references: :users, index: true
    add_foreign_key :feedbacks, :users, column: :to_user_id
  end
end
