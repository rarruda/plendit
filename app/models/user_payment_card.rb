class UserPaymentCard < ActiveRecord::Base
  has_paper_trail


  belongs_to :user


  # Never show "deleted" cards. (inactive)
  default_scope { where( 'active = true' ) }
  #user_id: current_user.id,
  #FIXME: dont ever show cards that belong to other users...

  validates_uniqueness_of :guid

  validate :user_is_provisioned

  before_validation :set_guid, :on => :create

  # We should never wipe cards from our system, but if we do, disable them first:
  before_destroy :disable,
    if: :card_vid?,
    if: :active?


  def set_favorite
    Location.transaction do
      self.update(favorite: true)
      self.user.user_payment_cards.where.not(id: self.id).each { |l| l.update(favorite: false) }
    end
  end

  def disable
    if self.last_known_status_mp == 'VALIDATED'
      mp = MangopayService( self.user ).card_disable( self.card_vid )
      LOG.info "deprovision_from_mangopay: #{mp}"
    else
      LOG.info "wont deprovision_from_mangopay a non-validated card: #{self}", { user_id: self.user.id, card_id: self.id }
    end
    self.active_mp = false
  end

  def to_param
    self.guid
  end

  private
  def user_is_provisioned
    if self.user.payment_provider_vid.blank?
      errors[:base] << "You are not yet provisioned with mangopay"
    end
  end


  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
