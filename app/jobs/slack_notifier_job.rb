class SlackNotifierJob < ActiveJob::Base
  queue_as :slack

  def do_slack_notification text, options = {}
  	Utils::SlackNotifier.instance.notify(text, options)
  end

end
