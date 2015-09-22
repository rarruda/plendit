class UserPaymentCard < ActiveRecord::Base
  has_paper_trail #:ignore => [:access_key, :preregistration_data, :registration_data, :card_registration_url]


  belongs_to :user


  # Never show "deleted" cards. (inactive)
  default_scope { where( 'active_mp = true' ) }
  #user_id: current_user.id,
  #FIXME: dont ever show cards that belong to other users...

  validates_uniqueness_of :guid


  before_validation :set_guid, :on => :create

  # We should never wipe cards from our system, but if we do, disable them first:
  before_destroy :disable,
    if: :card_vid?,
    if: :active_mp?


  def to_param
    self.guid
  end

  def disable
    if self.last_known_status_mp == 'VALIDATED'
      mp = MangopayService( self.user ).disable_registered_card( self.card_vid )
      logger.info "deprovision_from_mangopay: #{mp}"
    else
      logger.info "wont deprovision_from_mangopay a non-validated card: #{self}"
    end
    self.active_mp = false
  end

  private

  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
