class UserPaymentCard < ActiveRecord::Base
  include AASM

  has_paper_trail


  belongs_to :user

  has_many :financial_transactions, as: 'financial_transactionable'

  # used when pre/post-registering a card:
  attr_accessor :card_registration_id, :access_key, :preregistration_data, :card_registration_url, :registration_status
  attr_accessor :card_reg_vid, :registration_data

  # Never show "deleted" cards. (inactive)
  #  nor card_invalid?
  #default_scope { where( active: true ) }


  # mangopay status:  UNKNOWN                    VALID         INVALID
  enum validity:    { pending: 1, processing: 2, card_valid: 5, card_invalid: 10, errored: 11 }

  validates :guid,     uniqueness: true
  validates :user_id,  presence: true
  validates :card_vid, presence: true

  validate  :user_is_provisioned

  before_validation :set_guid, :on => :create

  # process! first refreshes the created card,
  #  and then triggers a delayed job to validated it.
  after_create :process!

  # We should never delete cards from our system, but if we do, it is imperative to disable them first:
  before_destroy :disable,
    if: :card_vid?,
    if: :active?


  aasm column: 'validity' do
    state :pending, initial: true
    state :processing
    state :card_valid
    state :card_invalid
    state :errored

    after_all_transitions :log_status_change

    event :process do
      transitions from: :pending, to: :processing
      before do
        refresh
      end
      after do
        # self.validate_on_mangopay
        UserPaymentCardValidateJob.perform_later( self )
      end
    end

    event :finish do
      transitions from: :processing, to: :card_valid
    end

    event :invalidate do
      transitions from: [:pending, :processing], to: :card_invalid
    end

    event :fail do
      transitions from: [:pending, :processing], to: :errored
    end

    event :revert do
      transitions from: [:pending,:processing], to: :pending
    end
  end

  def log_status_change
    LOG.info "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event}) for user_payment_card_id: #{self.id}"
  end

  def set_favorite
    UserPaymentCard.transaction do
      self.update(favorite: true)
      self.user.user_payment_cards.unscoped.where('id != ? AND user_id = ?', self.id, self.user_id).each { |l| l.update(favorite: false) }
    end
  end

  # Disable an existing card. This is the equivalent of deleting it.
  # Note: It is an irreversible action.
  def disable
    disabled_card = MangoPay::Card.update( self.card_vid, { 'Active' => false } )
    # only "true"/true are true. everything else is false:
    self.active = ( ["true" , true].include? disabled_card['Active'] )

    refresh

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

  # NOTE: for now we are doing everything in a syncronous fashion, but:
  # FIXME: this should be in a background job (or not, if it already called from a background job)
  # to validate we need to create a Charge, and then cancel it.
  # charges live in financial_transactions.
  # it takes around 28 seconds to go through this:
  def validate_on_mangopay
    LOG.info "Validating on mangoypay card: #{self.id}", { user_id: self.user_id, user_payment_card_id: self.id }
    t = create_financial_transaction_preauth_for_validation
    t.process!
    t.process_refresh!        unless t.errored?
    t.process_cancel_preauth! unless t.errored?
    refresh
  end

  private
  def create_financial_transaction_preauth_for_validation
    financial_transaction = {
      transaction_type: 'preauth',
      amount: MANGOPAY_CARD_VALIDATION_AMOUNT,
      fees:   0,
      src_type: :src_card_vid,
      src_vid:  self.card_vid,
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
