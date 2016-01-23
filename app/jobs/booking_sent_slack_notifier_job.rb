class BookingSentSlackNotifierJob < SlackNotifierJob

  def perform(*args)
  	self.do_slack_notification('a booking was sent')
  end
end
