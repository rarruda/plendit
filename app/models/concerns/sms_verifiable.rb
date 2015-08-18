module SmsVerifiable
  extend ActiveSupport::Concern

  #included do
  #end


  def current_phone_number
    self.unconfirmed_phone_number || self.phone_number
  end

    # do all transformations for phone_number confirmation.
  def confirm_phone_number!
    if self.unconfirmed_phone_number.nil?
      logger.tagged("user_id:#{self.id}") {
        logger.error "tried to confirm an unconfirmed_phone_number that is nil. This should never happen."
      }
      nil
    else
      self.phone_number              = self.unconfirmed_phone_number
      self.unconfirmed_phone_number  = nil
      self.phone_number_confirmed_at = Time.now
      self.phone_number_confirmation_token = nil

      self.save!
    end
  end

  def phone_verified?
    not self.phone_number.blank?
  end

  # is_phone_pending_confirmation?
  def phone_pending_confirmation?
    not unconfirmed_phone_number.nil?
  end

  def phone_pending_changed?
    unconfirmed_phone_number_changed?
  end

  private
  def set_phone_attributes
    #self.phone_number = false
    # 6 digit zero padded number as a string.
    self.phone_number_confirmation_token = ( SecureRandom.hex(3).to_i(16) % 1000000 ).to_s.rjust( 6, "0" )
    # removes all white spaces, hyphens, and parenthesis
    self.unconfirmed_phone_number.to_s.gsub!(/[\s\-\(\)]+/, '')
  end

  def send_sms_for_phone_confirmation
    PhoneVerificationService.new( user_id: id ).process
  end

end