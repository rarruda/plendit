class BookingSentSlackNotifierJob < SlackNotifierJob

  def perform(booking)
    self.do_slack_notification("A booking request for \"#{booking.ad.title}\" was sent.")
  end
end
