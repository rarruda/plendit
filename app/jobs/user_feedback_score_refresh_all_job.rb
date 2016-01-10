class UserFeedbackScoreRefreshAllJob < ActiveJob::Base
  queue_as :low

  def perform
    puts "#{DateTime.now.iso8601} Starting #{self.class.name}"
    # NOTE: should add a filter for only users
    #  which had bookings that ended in the last day or so.
    #  filter only for mangopay_provisioned users:
    User.all.select(&:mangopay_provisioned?).map{ |u|
      u.feedback_score_refresh
      # should possibly re-index ads for this user, if his rating changed
      #  across a threshold (eg. 3.24 -> 3.26, if 3.25 is a limit value ).
      u.save
    }

    puts "#{DateTime.now.iso8601} Ending #{self.class.name}"
  end
end
