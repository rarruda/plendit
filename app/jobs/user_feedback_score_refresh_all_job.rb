class UserFeedbackScoreRefreshAllJob < ActiveJob::Base
  queue_as :low

  def perform
    puts "#{DateTime.now.iso8601} Starting UserFeedbackScoreRefreshAllJob"
    # NOTE: should add a filter for only users
    #  which had bookings that ended in the last day or so.
    #  filter only for mangopay_provisioned users:
    User.all.select(&:mangopay_provisioned?).map(&:feedback_score_refresh)

    puts "#{DateTime.now.iso8601} Ending UserFeedbackScoreRefreshAllJob"
  end
end
