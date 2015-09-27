class PhoneVerificationService

  def initialize(options)
    @user = User.find( options[:user_id] )
  end

  def process
    send_sms
    @user.phone_number_confirmation_sent_at = Time.now
  end

  private

  # check that the to field is a valid norwegian phone number:
  def valid_to?
    ( @user.unconfirmed_phone_number.length == 8 and
      ( not @user.unconfirmed_phone_number.blank? ) and
      ['4','9'].include? @user.unconfirmed_phone_number[0]
    ) ? true : false
  end

  def from
    # Add your twilio phone number (programmable phone number)
    ENV['PCONF_TWILIO_NUM_FROM']
  end

  def to
    @user.unconfirmed_phone_number.blank? ? nil : "#{PLENDIT_COUNTRY_PHONE_CODE}#{@user.unconfirmed_phone_number}"
  end

  def body
    # TRANSLATEME:
    "Plendit: Please use this code '#{@user.phone_number_confirmation_token}' to verify your phone number. Never share this code with anyone."
  end

  def send_sms
    if to.blank?
      Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.error "unconfirmed_phone_number for user cannot be blank. Refusing to send sms." }
    elsif not valid_to?
      Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.error "unconfirmed_phone_number is not a valid norwegian mobile number. Refusing to send sms." }
    else
      Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.info "SMS: From: #{from} To: #{to} Body: '#{body}'" }

      if ENV['PCONF_TWILIO_ENABLED']
        # this should be done via a delayed job of some sort:
        begin
          TWILIO_CLIENT.account.messages.create( from: from, to: to, body: body )
        rescue => e
          Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.error "Error from Twilio API sending SMS: exception: #{e}" }
          Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.error "Error from Twilio API sending SMS: From: #{from} To: #{to} Body: '#{body}'" }
          # FIXME: Need to raise an warning to the user that we could not send an sms to the user. most likely an invalid number....
        end
      else
        Rails.logger.tagged("user_id:#{@user.id}") { Rails.logger.info "SMS: twilio not called to save money" }
      end
    end
  end
end