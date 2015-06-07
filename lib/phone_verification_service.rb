class PhoneVerificationService
  attr_reader :user

  def initialize(options)
    @user = User.find( options[:user_id] )
  end

  def process
    send_sms
    @user.phone_number_confirmation_sent_at = Time.now
  end

  private

  def from
    # Add your twilio phone number (programmable phone number)
    ENV['PCONF_TWILIO_NUM_FROM']
  end

  def to
    # +47 is a country code for Norway
    "+47#{@user.unconfirmed_phone_number}"
  end

  def body
    # /user/:id/verify/phone/{:token}
    "Plendit: Please use this code '#{user.phone_number_confirmation_token}' to verify your phone number."
  end

  def twilio_client
    # Pass your twilio account sid and auth token
    @twilio ||= Twilio::REST::Client.new(ENV['PCONF_TWILIO_ACCOUNT_SID'],
                                         ENV['PCONF_TWILIO_AUTH_TOKEN'])
  end

  def send_sms
    Rails.logger.tagged("user_id:#{@user.id}") do
      Rails.logger.info "SMS: From: #{from} To: #{to} Body: \"#{body}\""
    end

    twilio_client.account.messages.create(
      from: from,
      to: to,
      body: body
    )
  end
end