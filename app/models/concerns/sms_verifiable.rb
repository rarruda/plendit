module SmsVerifiable
  extend ActiveSupport::Concern

  #included do
  #end


  def current_phone_number
    self.unconfirmed_phone_number if not self.unconfirmed_phone_number.blank?
    self.phone_number
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
    not self.phone_number.blank?
  end

  # is_phone_pending_confirmation?
  def phone_pending_confirmation?
    if self.phone_number.blank? or not self.unconfirmed_phone_number.blank?
      true
    else
      false
    end
  end

  def sms_sending_cool_off_elapsed?
    return true if self.phone_number_confirmation_sent_at.blank?
    ( Time.now > self.phone_number_confirmation_sent_at + SMS_COOL_OFF_PERIOD )
  end

  private
  # create confirmation token if a user wants to change his phone number.
  def set_phone_attributes
    # 6 digit zero padded number as a string.
    self.phone_number_confirmation_token = ( SecureRandom.hex(3).to_i(16) % 1_000_000 ).to_s.rjust( 6, "0" )
    # removes all white spaces, hyphens, and parenthesis
    self.unconfirmed_phone_number.to_s.gsub!(/[\s\-\(\)]+/, '')
  end

  def send_sms_for_phone_confirmation
    if self.sms_sending_cool_off_elapsed? || self.phone_number_confirmation_sent_at.blank?
      self.phone_number_confirmation_sent_at = Time.now
      LOG.info "Sending SMS for verification", {user_id: self.id, phone_number: self.phone_number}
      PhoneVerificationService.new( user_id: id ).process
    else
      LOG.info "NOT Sending SMS for verification, as a previous attempt was done at #{self.phone_number_confirmation_sent_at}, which is less then #{SMS_COOL_OFF_PERIOD} seconds ago.",
        user_id: self.id,
        phone_number_confirmation_sent_at: self.phone_number_confirmation_sent_at,
        phone_number: self.phone_number
    end
  end

end