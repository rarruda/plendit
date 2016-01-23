class UserJoinedSlackNotifierJob < SlackNotifierJob

  def perform(*args)
  	self.do_slack_notification('new user joined')
  end
end
