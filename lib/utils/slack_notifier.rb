class Utils::SlackNotifier

  def self.instance
    @instance ||= new()
  end

  def initialize
    if Rails.env.production? && ENV['SLACK_NOTIFICATION_WEBHOOK_URL']
      @notifier = Slack::Notifier.new(
        ENV['SLACK_NOTIFICATION_WEBHOOK_URL'],
        channel: ENV['SLACK_NOTIFICATION_CHANNEL']   || '#notifications-events',
        username: ENV['SLACK_NOTIFICATION_USERNAME'] || 'plendbot',
        icon_emoji: ENV['SLACK_NOTIFICATION_EMOJI']  || ':happybot:'
       )
    else
      @notifier = (Slack::Notifier.new 'http://localdev.example.org', http_client: NoOpHTTPClient)
    end
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
