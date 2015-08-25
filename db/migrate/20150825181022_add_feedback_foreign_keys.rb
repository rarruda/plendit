class AddFeedbackForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :feedbacks, :users, column: :from_user_id
    add_foreign_key :feedbacks, :ads
  end
end
