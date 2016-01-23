class KycUploadedSlackNotifierJob < SlackNotifierJob

  def perform(*args)
    self.do_slack_notification('New kyc doc uploaded')
  end
end
