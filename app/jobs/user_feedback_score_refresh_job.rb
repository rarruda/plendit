class UserFeedbackScoreRefreshJob < ActiveJob::Base
  queue_as :low

  # NOTE: this job is not currently used anywhere.
  def perform user
    puts "#{DateTime.now.iso8601} Starting #{self.class.name}"

    user.feedback_score_refresh
    user.save

    puts "#{DateTime.now.iso8601} Ending #{self.class.name}"
  end
end
