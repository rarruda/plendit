class AdSubmittedSlackNotifierJob < SlackNotifierJob

  def perform(ad)
    self.do_slack_notification(
      "New ad submitted for review: #{ad.title}",
      url: Rails.application.routes.url_helpers.ad_url(ad)
    )
  end

end
