class SmsService

  def initialize( sms_to, sms_body)
    @sms_to   = sms_to
    @sms_body = sms_body
  end

  def process
    send_sms
  end

  private

  # check that the to field is a valid norwegian phone number:
  def valid_to?
    return true if ( not @sms_to.blank? ) && ( @sms_to.length == 8 ) && ( ['4','9'].include? @sms_to[0] )
    false
  end

  def from
    # Add your twilio phone number (programmable phone number)
    ENV['PCONF_TWILIO_NUM_FROM']
  end

  def send_sms
    if not valid_to?
      LOG.error message: "sms_to is not a valid norwegian mobile number. Refusing to send sms.", sms_to: @sms_to
    else
      LOG.info message: "SMS: From: #{from} To: #{@sms_to} Body: '#{@sms_body}'", sms_to: @sms_to

      if ENV['PCONF_TWILIO_ENABLED']
        # this should be done via a delayed job of some sort:
        begin
          TWILIO_CLIENT.account.messages.create( from: from, to: @sms_to, body: @sms_body )
        rescue => e
          LOG.error message: "Error from Twilio API sending SMS: From: #{from} To: #{@sms_to} Body: '#{@sms_body}' exception: #{e}", sms_to: @sms_to
          # Just send the exception down the stack. most likely an invalid number....
          raise
        end
      else
        LOG.info message: "SMS: twilio not called to save money", sms_to: @sms_to
      end
    end
  end
end