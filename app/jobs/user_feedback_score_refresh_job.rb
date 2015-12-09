class UserFeedbackScoreRefreshJob < ActiveJob::Base
  queue_as :low

  # NOTE: this job is not currently used anywhere.
  def perform user_id = nil
    raise "Need a user_id as a parameter to refresh the feedback_score parameter" if user_id.nil?
    User.find(user_id).feedback_score_refresh
  end
end
