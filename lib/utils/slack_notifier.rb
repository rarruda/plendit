class Utils::SlackNotifier

  def self.instance
    @instance ||= new()
  end

  def initialize
    @notifier = Slack::Notifier.new(
      ENV['PCONF_SLACK_NOTIFICATION_WEBHOOK_URL'],
      channel:     ENV['PCONF_SLACK_NOTIFICATION_CHANNEL']  || '#notifications-events',
      username:    ENV['PCONF_SLACK_NOTIFICATION_USERNAME'] || 'plendbot',
      icon_emoji:  ENV['PCONF_SLACK_NOTIFICATION_EMOJI']    || ':happybot:',
      http_client: Rails.env.production? ? Slack::Notifier::DefaultHTTPClient : NoOpHTTPClient
    )
  end

  def notify message, options = {}
    if options.has_key? :url
      message = "#{message} - [#{options[:link_text] || 'Åpne'}](#{options[:url]})"
    end
    @notifier.ping message
  end

  private
  class NoOpHTTPClient
    def self.post uri, params = {}
      # if you need to see what would have been sent, uncomment the next line
      pp params
    end
  end

end
