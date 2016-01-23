class Utils::SlackNotifier

  def self.instance
    @instance ||= new()
  end

  def initialize
    channel = ENV['SLACK_NOTIFICATION_CHANNEL']   || '#site-events'
    username = ENV['SLACK_NOTIFICATION_USERNAME'] || 'plendbot'
    icon_emoji = ENV['SLACK_NOTIFICATION_EMOJI']  || ':happybot:'
    client = nil

    unless Rails.env.production?
      channel = "#{channel}-#{Rails.env}"
      client = NoOpHTTPClient
    end

    @notifier = Slack::Notifier.new(
      ENV['SLACK_NOTIFICATION_WEBHOOK_URL'],
      channel: channel,
      username: username,
      icon_emoji: icon_emoji,
      http_client: client
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
