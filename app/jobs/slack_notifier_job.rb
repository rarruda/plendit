class SlackNotifierJob < ActiveJob::Base
  queue_as :slack

  # only supported parameter for options is :url
  #  which would have a url to where to link to the message.
  def perform text, options = {}
    Utils::SlackNotifier.instance.notify(text, options)
  end

end
