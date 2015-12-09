class UserFeedbackScoreRefreshJob < ActiveJob::Base
  queue_as :low

  def perform
    # NOTE: should add a filter for only users
    #  which had bookings that ended in the last day or so.
    User.all.map(&:feedback_score_refresh)
    # NOTE: should write to log how long it took to run the job.
  end
end
