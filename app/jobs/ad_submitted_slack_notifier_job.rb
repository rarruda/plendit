class AdSubmittedSlackNotifierJob < ActiveJob::Base
  queue_as :slack

  def perform(ad)
	Utils::SlackNotifier.instance.notify(
		"New ad submitted for review: #{ad.title}",
		url: Rails.application.routes.url_helpers.ad_url(ad)
	)
  end
end
