class UserPaymentCard < ActiveRecord::Base
  has_paper_trail


  belongs_to :user

  # used when pre-registering a card:
  attr_accessor :card_registration_id, :access_key, :preregistration_data, :card_registration_url, :registration_status

  # Never show "deleted" cards. (inactive)
  default_scope { where( active: true ) }


  #                CREATED                    UNKNOWN              VALID     INVALID
  #enum state:    { pending: 1, processing: 2, unknown_validity: 4, _valid: 5, invalid: 10 }

  validates :guid,     uniqueness: true
  validates :user_id,  presence: true
  validates :card_vid, presence: true

  validate :user_is_provisioned

  before_validation :set_guid, :on => :create
  before_create :refresh


  # We should never delete cards from our system, but if we do, it is imperative to disable them first:
  before_destroy :disable,
    if: :card_vid?,
    if: :active?


  def set_favorite
    UserPaymentCard.transaction do
      self.update(favorite: true)
      self.user.user_payment_cards.where('id != ? AND user_id = ?', self.id, self.user_id).each { |l| l.update(favorite: false) }
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

  def pre_register
    begin
      card_reg = MangoPay::CardRegistration.create(
        'Tag'      => "user_id=#{self.user_id}",
        'UserId'   => self.user.payment_provider_vid,
        'Currency' => MANGOPAY_CURRENCY_CODE,
        'CardType' => MANGOPAY_DEFAULT_CARD_TYPE
      )

      self.attributes = {
        card_registration_id:  card_reg['Id'],
        access_key:            card_reg['AccessKey'],
        preregistration_data:  card_reg['PreregistrationData'],
        card_registration_url: card_reg['CardRegistrationURL'],
        registration_status:   card_reg['Status']
      }
    rescue => e
      LOG.error "Error pre-registering card: #{e}", { user_id: self.user_id }
    end
  end

  private
  def refresh
    unless self.card_vid.blank?
      self.attributes ||= @mangopay.card_fetch( self.card_vid )
    else
      LOG.error "unable to load information from mangopay as card_vid is blank", { user_id: self.user.id, card_id: self.id }
    end
  end

  def user_is_provisioned
    unless self.user.mangopay_provisioned?
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
