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
    @user.unconfirmed_phone_number ? "+47#{@user.unconfirmed_phone_number}" : nil
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
    if to.nil?
      Rails.logger.tagged("user_id:#{@user.id}") do
        Rails.logger.error "unconfirmed_phone_number for user cannot be nil. Refusing to send sms."
      end
    else
      Rails.logger.tagged("user_id:#{@user.id}") do
        Rails.logger.info "SMS: From: #{from} To: #{to} Body: \"#{body}\""
      end

      if ENV['PCONF_TWILIO_ENABLED']
        twilio_client.account.messages.create(
          from: from,
          to: to,
          body: body
        )
      else
        Rails.logger.tagged("user_id:#{@user.id}") do
          Rails.logger.info "SMS: twilio not called to save money"
        end
      end
    end
  end
end