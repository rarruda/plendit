class KycUploadedSlackNotifierJob < SlackNotifierJob

  def perform(doc)
    self.do_slack_notification("User #{doc.user.name} uloaded kyc doc of type #{doc.decorate.display_category}.")
  end
end
