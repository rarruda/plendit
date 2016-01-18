module SmsVerifiable
  extend ActiveSupport::Concern

  def current_phone_number
    self.unconfirmed_phone_number.blank? ? self.phone_number : self.unconfirmed_phone_number
  end

  def current_phone_number= number
    if self.phone_number == number
      self.unconfirmed_phone_number = nil
    else
      self.unconfirmed_phone_number = number
    end
  end

  # do all transformations for phone_number confirmation.
  def confirm_phone_number!
    if self.unconfirmed_phone_number.nil?
      LOG.error "tried to confirm an unconfirmed_phone_number that is nil. This should never happen.", { user_id: self.id }
      nil
    else
      self.phone_number              = self.unconfirmed_phone_number
      self.unconfirmed_phone_number  = nil
      self.phone_number_confirmed_at = Time.now
      self.phone_number_confirmation_token   = nil
      self.phone_number_confirmation_sent_at = nil

      self.save!
    end
  end

  def phone_verified?
    self.phone_number.present?
  end

  # do not let invalid unconfirmed_phone_number be pending confirmation:
  def phone_pending_confirmation?
    self.unconfirmed_phone_number.present? && self.errors[:unconfirmed_phone_number].empty?
  end

  def sms_sending_cool_off_elapsed?
    return true if self.phone_number_confirmation_sent_at.blank?
    ( Time.now > self.phone_number_confirmation_sent_at + SMS_COOL_OFF_PERIOD )
  end

  def send_sms_for_phone_confirmation
    if self.sms_sending_cool_off_elapsed?
      self.phone_number_confirmation_sent_at = Time.now

      LOG.info "Sending SMS for verification", {user_id: self.id, unconfirmed_phone_number: self.unconfirmed_phone_number}
      sms_body = "Plendit: '#{self.phone_number_confirmation_token}'. Bruk denne koden for å bekrefte mobilnummeret ditt. Hilsen Plendit. P.S. Ikke del denne koden med noen!"

      begin
        SmsService.new( unconfirmed_phone_number, sms_body ).process
      #rescue Twilio::REST::RequestError => e
      rescue => e
        @notices ||= []
        @notices << 'Klarte ikke å sende SMS'
        #self.errors.add(:phone_number , 'Klarte ikke å sende SMS')

      end
    else
      LOG.info "NOT Sending SMS for verification, as a previous attempt was done at #{self.phone_number_confirmation_sent_at}, which is less then #{SMS_COOL_OFF_PERIOD} seconds ago.",
        user_id: self.id,
        phone_number_confirmation_sent_at: self.phone_number_confirmation_sent_at,
        unconfirmed_phone_number: self.unconfirmed_phone_number
      @notices ||= []
      @notices << 'Det ble nydelig sendt en SMS. Prøv igjen om litt.'
    end
  end

  private
  # create confirmation token if a user wants to change his phone number.
  def set_phone_attributes
    # 6 digit zero padded number as a string.
    self.phone_number_confirmation_token = ( SecureRandom.hex(3).to_i(16) % 1_000_000 ).to_s.rjust( 6, "0" )
    # removes all white spaces, hyphens, and parenthesis
    self.unconfirmed_phone_number.to_s.gsub!(/[\s\-\(\)]+/, '')
    self.phone_number_confirmation_sent_at = nil
  end

end