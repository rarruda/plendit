class AddFeedbackScoringToUser < ActiveRecord::Migration
  def change
    add_column :users, :feedback_score,            :float,   default: 0
    add_column :users, :feedback_score_count,      :integer, default: 0
    add_column :users, :feedback_score_updated_at, :datetime
  end
end
