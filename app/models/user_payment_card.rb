class UserPaymentCard < ActiveRecord::Base
  include AASM

  has_paper_trail


  belongs_to :user

  has_many :validation_transactions, as: 'financial_transactionable'

  # used when pre/post-registering a card:
  attr_accessor :card_registration_id, :access_key, :preregistration_data, :card_registration_url, :registration_status
  attr_accessor :card_reg_vid, :registration_data

  # Never show "deleted" cards. (inactive)
  default_scope { where( active: true ) }


  # mangopay status:  UNKNOWN                    VALID         INVALID
  enum validity:    { pending: 1, processing: 2, card_valid: 5, card_invalid: 10, errored: 11 }

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


  aasm column: 'validity' do
    state :pending, initial: true
    state :processing
    state :card_valid
    state :card_invalid
    #state :errored

    event :process, after: :validate_on_mangopay do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :card_valid
    end

    event :invalidate do
      transitions from: :processing, to: :card_invalid
    end

    event :fail do
      transitions from: :processing, to: :errored
    end

    event :revert do
      transitions from: [:pending,:processing], to: :pending
    end
  end


  def set_favorite
    UserPaymentCard.transaction do
      self.update(favorite: true)
      self.user.user_payment_cards.where('id != ? AND user_id = ?', self.id, self.user_id).each { |l| l.update(favorite: false) }
    end
  end

  # Disable an existing card. This is the equivalent of deleting it.
  # Note: It is an irreversible action.
  def disable
    disabled_card = MangoPay::Card.update( self.card_vid, { 'Active' => false } )
    # only "true"/true are true. everything else is false:
    self.active = ( ["true" , true].include? disabled_card['Active'] )
    self.save

    #self.refresh #?

    LOG.info "deactivated from mangopay: #{self}", { user_id: self.user.id, card_id: self.id }
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

  def register
    begin
      card = MangoPay::CardRegistration.update(
        self.card_reg_vid,
        { 'RegistrationData' => self.registration_data }
      )
      self.card_vid = card['CardId']
    rescue => e
      LOG.error "Error: #{e} registering card: #{card}", { user_id: self.user_id }
    end
  end

  private

  # FIXME: this should be in a background job (or not, if it already called from a background job)
  # to validate we need to create a Charge, and then cancel it.
  # charges live in financial_transactions.
  def validate_on_mangopay
    t = create_financial_transaction_preauth_for_validation
    t.process!
    t.process_refresh!
    t.process_cancel_preauth!
    refresh
  end

  def create_financial_transaction_preauth_for_validation
    financial_transaction = {
      transaction_type: 'preauth',
      amount: MANGOPAY_CARD_VALIDATION_AMOUNT,
      fees:   0,
    }
    self.financial_transactions.create( financial_transaction )
  end

  def refresh
    card = card_translate( MangoPay::Card.fetch self.card_vid )

    self.update( card.except(:validity) )
    case card[:validity]
    when 'UNKNOWN'
      self.revert!
      #same as: self.validity = 'pending'
    when 'VALID'
      self.finish!
    when 'INVALID'
      self.invalidate!
    else
      self.fail!
    end
  end


  def card_translate ( mp_card )
    return nil if mp_card.blank? || ! ( mp_card.is_a? Hash )

    # card_vid was the key for the lookup, so not translating it.
    {
      #card_vid:        mp_card['Id'],
      card_type:       mp_card['CardType'],
      card_provider:   mp_card['CardProvider'],
      currency:        mp_card['Currency'],
      country:         mp_card['Country'],
      number_alias:    mp_card['Alias'],
      expiration_date: mp_card['ExpirationDate'],
      validity:        mp_card['Validity'],
      active:          mp_card['Active']
    }
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
