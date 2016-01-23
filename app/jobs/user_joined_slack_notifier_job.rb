class UserJoinedSlackNotifierJob < SlackNotifierJob

  def perform(user)
    self.do_slack_notification("New user joined: #{user.decorate.display_name}")
  end
end
