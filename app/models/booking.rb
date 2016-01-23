class Booking < ActiveRecord::Base
  include Comparable
  include AASM

  extend TimeSplitter::Accessors

  split_accessor :starts_at
  split_accessor :ends_at

  has_paper_trail


  belongs_to :ad_item
  belongs_to :from_user,      class_name: 'User'
  belongs_to :user_payment_card

  has_one :ad,                through: :ad_item
  has_one :user,              through: :ad
  has_many :feedbacks         #,dependent: :destroy
  has_many :messages          #,dependent: :destroy
  has_many :accident_reports  #,dependent: :destroy
  has_many :financial_transactions, as: 'financial_transactionable', dependent: :restrict_with_exception

  # fields which doesnt make any sense to persist to the database:
  # but are needed for the booking flow:
  attr_accessor :secure_mode_redirect_url, :secure_mode_needed

  enum status: {
    created:               0,
    payment_preauthorized: 1,
    confirmed:             2,
    payment_confirmed:     3,
    started:               4,
    in_progress:           6,
    ended:                 8,
    archived:              9,
    aborted:              10,
    cancelled:            11,
    declined:             12,
    payment_preauthorization_failed: 13,
    payment_failed:       14,
    disputed:             40,
    dispute_agreed:       41,
    dispute_disagreed:    42,
    admin_paused:         99
  }

  #default_scope { where( status: active ) }

  scope :has_user,   ->(user) { joins(:ad).where( 'from_user_id = ? OR ads.user_id = ?', user.id, user.id ) }
  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  scope :accidents_reportable,
                     -> { where( status: [ self.statuses[:started], self.statuses[:in_progress], self.statuses[:ended] ] ) }
  # IF should only see these bookings:
  scope :boat_insurer_visible,
                     -> { joins(:ad).where( status: [ self.statuses[:confirmed], self.statuses[:payment_confirmed], self.statuses[:started],
                                           self.statuses[:in_progress], self.statuses[:ended] ],
                                           ads: { category: Ad.categories[:boat] }
                                           ) }
  # current: bookings that are confirmed paid.
  scope :current,    -> { where( status: [ self.statuses[:confirmed], self.statuses[:payment_confirmed], self.statuses[:started],
                                           self.statuses[:in_progress], self.statuses[:ended] ] ) }
  # active: bookings that should be going on now:
  scope :active,     -> { where( status: [ self.statuses[:started], self.statuses[:in_progress] ] ) }

  # reserved: we have an existing booking, and cannot have another booking in parallel to one in these states.
  # there might be more states here that should count as reserved.
  # Probably we will make some more helpers for check states.
  scope :reserved,   -> { where( status: [ self.statuses[:confirmed], self.statuses[:payment_confirmed], self.statuses[:started],
                                           self.statuses[:disputed], self.statuses[:in_progress] ] ) }

  scope :created,    -> { where( status: self.statuses[:created] ) }
  scope :payment_preauthorized,
                     -> { where( status: self.statuses[:payment_preauthorized] ) }
  scope :confirmed,  -> { where( status: self.statuses[:confirmed] ) }
  scope :in_progress,-> { where( status: self.statuses[:in_progress] ) }
  scope :started,    -> { where( status: self.statuses[:started] ) }
  scope :ended,      -> { where( status: self.statuses[:ended] ) }
  scope :payment_confirmed,
                     -> { where( status: self.statuses[:payment_confirmed] ) }


  scope :ad_item,    ->(ad_item_id) { where( ad_item_id: ad_item_id ) }
  scope :in_month,   ->(year,month) { where( 'ends_at >= ? and starts_at <= ?',
    DateTime.new(year, month).beginning_of_month, DateTime.new(year, month).end_of_month ) }
  scope :in_between, ->(start_date,end_date) { where( 'ends_at >= ? and starts_at <= ?', start_date, end_date) }

  scope :exclude_past,   ->{ where( 'ends_at >= ?', DateTime.now ) }



  validates :starts_at, :ends_at, overlap: {
    scope:         'ad_item_id',
    query_options: { active: nil }
  }
  validate :validate_starts_at_before_ends_at
  validate :validate_starts_at,    on: :create
  validate :validate_ends_at,      on: :create

  validates :guid,                 uniqueness: true
  validates :ad_item_id,           presence: true
  validates :from_user_id,         presence: true
  validates :user_payment_card_id, presence: true
  validates :amount,               numericality: { only_integer: true }
  validates :amount,               numericality: { greater_than_or_equals: 99_00, message: 'Må være minst 99kr' }
  validates :amount,               numericality: { less_than:          25_000_00, message: 'Kan ikke være mer enn 25.000 kroner' }
  # https://docs.mangopay.com/api-references/payins/ actual limit is 2500 eur in general...

  validates :deposit_amount,       numericality: { only_integer: true }
  validates :deposit_offer_amount, numericality: { only_integer: true }
  validates :deposit_offer_amount, numericality: { greater_than_or_equal_to: 0, message: 'Kan ikke være en negativ tall' } #TRANSLATEME

  validate :validate_deposit_offer_amount_less_than_or_equals_deposit_amount,
    if: "deposit_offer_amount.present?"

  validate :validate_user_payment_card_belongs_to_from_user

  # write validation to check that the from_user has enough id
  # to be able to create a valid booking:
  validate :validate_from_user_can_create_booking


  before_validation :align_times, on: :create
  before_validation :set_guid,    on: :create
  before_validation :calculate!,
    if: :starts_at_changed?,
    if: :ends_at_changed?

  before_validation :calculate_fee,
    if: :starts_at_changed?,
    if: :ends_at_changed?,
    if: :payout_amount_changed?

  before_validation :calculate_insurance,
    if: :starts_at_changed?,
    if: :ends_at_changed?,
    if: :payout_amount_changed?

  # NOTE: we do not allow editing bookings.
  #  If we did, the following callback would not be enough.
  after_create :create_financial_transaction_preauth

  aasm column: :status, enum: true do
    state :created, initial: true
    state :payment_preauthorized
    state :confirmed
    state :payment_confirmed
    state :started
    state :in_progress
    state :ended
    state :archived

    state :aborted
    state :cancelled
    state :declined
    state :payment_preauthorization_failed
    state :payment_failed

    state :disputed
    state :dispute_agreed
    state :dispute_disagreed

    state :admin_paused

    after_all_transitions :log_status_change

    event :payment_preauthorize do
      transitions from: :created, to: :payment_preauthorized
      after do
        # send emails to owner, asking for confirmation...
        ApplicationMailer.booking_created__to_owner( self ).deliver_later
        Notification.create(
          user_id: self.user.id,
          message: "#{self.from_user.decorate.display_name} ønsker å leie \"#{self.ad.decorate.display_title}\"",
          notifiable: self
        )
      end
    end

    event :confirm do
      transitions from: :payment_preauthorized, to: :confirmed
      after do
        # FIXME!!: check if no transactions exist already?
        create_financial_transaction_payin

        ApplicationMailer.booking_confirmed__to_owner( self ).deliver_later
        ApplicationMailer.booking_confirmed__to_renter( self ).deliver_later
      end
    end

    event :payment_confirm do
      transitions from: :confirmed, to: :payment_confirmed
      after do
        BookingAutoStartJob.set(wait_until: self.starts_at).perform_later self

        Notification.create(
          user_id: self.from_user.id,
          message: "#{self.user.decorate.display_name} har godkjent din forespørsel om å leie \"#{self.ad.decorate.display_title}\"",
          notifiable: self
        )
      end
    end

    event :abort do
      transitions from: :payment_preauthorized, to: :aborted
      after do
        BookingCancelPreauthJob.perform_later self

        Notification.create(
          user_id: self.user.id,
          message: "#{self.from_user.decorate.display_name} har kansellert booking forespørsel om å leie \"#{self.ad.decorate.display_title}\"",
          notifiable: self
        )
      end
    end

    event :decline do
      transitions from: :payment_preauthorized, to: :declined
      after do
        BookingCancelPreauthJob.perform_later self

        ApplicationMailer.booking_declined__to_renter( self ).deliver_later
        Notification.create(
          user_id: self.from_user.id,
          message: "#{self.user.decorate.display_name} har avslått din forespørsel om å leie \"#{self.ad.decorate.display_title}\"",
          notifiable: self
        )
      end
    end

    #after: :refund_payin
    event :cancel do
      transitions from: [:confirmed,:payment_confirmed,:started], to: :cancelled do
        guard do
          # confirmed, payment_confirmed or if started, can still cancel within 24hours.
          self.confirmed? || self.payment_confirmed? || ( self.started? && ( DateTime.now < self.starts_at + 1.day ) )
        end
      end
      after do
        cancel_all_financial_transactions_payin

        ApplicationMailer.booking_cancelled__to_owner( self ).deliver_later
        ApplicationMailer.booking_cancelled__to_renter( self ).deliver_later

        Notification.create(
          user_id: self.user.id,
          message: "#{self.from_user.decorate.display_name} har kansellert bookingen på \"#{self.ad.decorate.display_title}\"",
          notifiable: self
        )
      end
    end

    event :start do
      transitions from: :payment_confirmed, to: :started

      after do
        LOG.info message: "schedule auto-set_in_progress as new status in 1.day...(#{self.in_progress_at})", booking_id: self.id
        # or right before ends_at if its a same day booking.
        BookingAutoSetInProgressJob.set(wait_until: self.in_progress_at ).perform_later self
      end
    end

    event :set_in_progress do
      transitions from: :started, to: :in_progress

      after do
        LOG.info message: "make transfer of funds...", booking_id: self.id
        create_financial_transaction_transfer_rental

        LOG.info message: "schedule auto-end at ends_at(#{self.ends_at})...", booking_id: self.id
        BookingAutoEndJob.set(wait_until: self.ends_at ).perform_later self
      end
    end

    event :end do
      transitions from: :in_progress, to: :ended
      after do
        LOG.info message: "schedule auto-archival 7 days after ends_at.", booking_id: self.id
        BookingAutoArchiveJob.set(wait_until: self.archives_at ).perform_later self

        if self.deposit_offer_amount > 0
          create_financial_transaction_transfer_deposit
          ApplicationMailer.deposit_withdrawals__to_owner( self ).deliver_later
        else
          LOG.info message: "No need to create a transfer for deposit, as it would be <= 0 NOK", booking_id: self.id
        end

        Notification.create(
          user_id: self.user.id,
          is_system_message: true,
          message: "Du kan gi #{self.from_user.decorate.display_name} en tilbakemelding nå.",
          notifiable: self
        )

        Notification.create(
          user_id: self.from_user.id,
          is_system_message: true,
          message: "Du kan gi #{self.user.decorate.display_name} en tilbakemelding nå.",
          notifiable: self
        )
      end
    end

    event :archive do
      transitions from: :ended, to: :archived
      # UserFeedbackScoreRefreshAllJob should run weekly for all users as a safety net...
      after do
        if self.sum_deposit_available_for_refund > 0
          create_financial_transaction_refund_deposit
        else
          LOG.info message: "No need to create a refund, as it would be <= 0 NOK", booking_id: self.id
        end

        UserFeedbackScoreRefreshJob.set(wait_until: ( Date.tomorrow.beginning_of_day + 1.hour) ).perform_later self.from_user
        UserFeedbackScoreRefreshJob.set(wait_until: ( Date.tomorrow.beginning_of_day + 1.hour) ).perform_later self.user
      end
    end

    event :dispute do
      transitions from: :started, to: :disputed
    end

    event :dispute_agree do
      transitions from: :disputed, to: :dispute_agreed
    end

    event :dispute_disagree do
      transitions from: :disputed, to: :dispute_disagreed
    end

    event :payment_preauthorization_fail do
      transitions from: [:created, :payment_preauthorized], to: :payment_preauthorization_failed
    end

    event :payment_fail do
      transitions from: [:confirmed, :payment_confirmed], to: :payment_failed
    end

    # dont do anything. when manual intervention is required/exception handling:
    # tar-pit state.
    event :admin_pause do
      transitions from: [:created, :payment_preauthorized, :confirmed, :payment_confirmed, :started, :in_progress, :ended, :disputed], to: :admin_paused
    end
  end

  # FIXME: code duplicated at payin_rule model:
  def deposit_offer_amount_in_h
    return nil if self.deposit_offer_amount.nil?
    ( ( self.deposit_offer_amount / 100).to_i + ( self.deposit_offer_amount / 100.0  ).modulo(1) )
  end

  # save prices in integer, from human format input
  def deposit_offer_amount_in_h=( _deposit_offer_amount )
    self.deposit_offer_amount = ( _deposit_offer_amount.to_f * 100 ).round
  end

  def most_recent_activity
    message = self.messages.last
    message_time = message.created_at if message.present?

    if message_time.present? && message_time > self.updated_at
      :message
    else
      :status
    end
  end

  def may_send_damage_report?
    # after started, until 48hours after booking ended.
    self.started? || self.in_progress? || ( self.ended? && self.ends_at + 2.days < DateTime.now )
  end

  def may_give_feedback?
    # if status is ended, can give feedback
    self.ended?
  end

  def may_set_deposit_offer_amount?(user = nil)
    user.present? &&
    ( self.from_user.id == user.id ) &&
    self.ad.motor? &&
    ( self.started? || self.in_progress? )
    # || self.ended? && +24t?
  end

  def log_status_change
    LOG.info message: "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event}) for booking_id: #{self.id}",
      booking_id: self.id
  end

  def should_be_confirmed?
    self.payment_preauthorized? &&
    ( self.should_be_in_progress? ||
      ( DateTime.now > self.created_at + 7.days )
    )
  end

  def should_be_started?
    self.payment_confirmed? && ( DateTime.now > self.starts_at )
  end

  def should_be_in_progress?
    self.started? && ( DateTime.now > self.in_progress_at )
  end

  def should_be_ended?
    self.in_progress? && ( DateTime.now > self.ends_at )
  end

  def should_be_archived?
    self.ended? && ( DateTime.now > self.archives_at )
  end

  ###
  def in_progress_at
    if starts_at.to_date == ends_at.to_date
      # same day booking:
      ends_at - 1.minute
    else
      starts_at + 1.day
    end
  end

  def archives_at
    self.ends_at + 7.days + 1.second
  end

  def was_ever_confirmed?
    [
      self.confirmed?, self.payment_confirmed?, self.started?, self.in_progress?,
      self.ended?, self.archived?, self.disputed?, self.dispute_agreed?
    ].any?
  end

  def days
    # fixme: runeh: use ceil here now becuase the calculations is
    # a full day minus one second when start and end is same date
    ((self.ends_at - self.starts_at) / 1.day).ceil.to_i
  end

  # FIXME: temporarely in place just during a transition period.
  #  to be removed.
  def amount
    self.payout_amount
  end

  # FIXME: calling booking payin_amount just feels kinda wrong.
  #  should probably find a better name for it.
  def calculate!
    calculate_amount
    calculate_fee
    calculate_insurance
    calculate_deposit
  end

  def calculate_amount
    self.payout_amount = self.booking_calculator.payout_amount
  end

  def calculate_fee
    self.platform_fee_amount = self.booking_calculator.platform_fee
  end

  def calculate_insurance
    self.insurance_amount = self.booking_calculator.insurance_fee
  end

  def calculate_deposit
    self.deposit_amount = self.booking_calculator.deposit_amount
  end

  def sum_paid_to_owner
    self.payout_amount
  end

  def sum_paid_by_renter
    self.payout_amount + self.platform_fee_amount + self.insurance_amount
  end

  def sum_paid_by_renter_with_deposit
    self.sum_paid_by_renter + self.deposit_amount
  end

  def sum_paid_by_renter_per_day
    (self.payout_amount + self.platform_fee_amount + self.insurance_amount) / self.days
  end

  def sum_plaform_fee_and_insurance
    ( self.platform_fee_amount + self.insurance_amount )
  end

  # Might need to do something more fancy, as there might be multiple deposit_transfers...
  def sum_deposit_available_for_refund
    available_for_refund = ( self.deposit_amount - self.sum_transfer_deposit )

    ( available_for_refund > 0 ) ? available_for_refund : 0
  end

  def sum_transfer_deposit
    self.financial_transactions.transfer.deposit.map(&:amount).sum
  end

  ###
  def include?(date)
    ( date >= self.starts_at and date <= self.ends_at )
  end


  def date_status(date)
    #AVAILABILITY_STATUSES = ['booked', 'starting', 'ending', 'available']

    # I end before date.beginning_of_day
    if self.ends_at < date.to_datetime.beginning_of_day
      'available'
    # I start after date.end_of_day
    elsif self.starts_at > date.to_datetime.end_of_day
      'available'
    else
      # I start after date.beginning_of_day _and_ before date.end_of_day
      if self.starts_at > date.to_datetime.beginning_of_day and
        self.starts_at <= date.to_datetime.end_of_day
        'starting'
      # I end after date.beginning_of_day _and_ before date.end_of_day
      elsif self.ends_at > date.to_datetime.beginning_of_day and
        self.ends_at < date.to_datetime.end_of_day
        'ending'
      else
        ### hornets nest of possible partially available in that day/corner cases....
        #### (if something is rented for some hours within the day, the day will be marked as fully 'booked')
        'booked'
      end
    end
  end

  def validate_user_payment_card_belongs_to_from_user
    if self.from_user.user_payment_cards.unscoped.find_by( id: self.user_payment_card_id ).blank?
      errors.add(:user_payment_card, "Kortet må tilhøre bruker.")
    end
  end

  def validate_starts_at_before_ends_at
      errors.add(:end_at, "Til dato kan ikke være før fra dato.") if self.ends_at < self.starts_at
  end

  def validate_starts_at
      errors.add(:starts_at, "Fra dato kan ikke være i fortiden.") if self.starts_at < DateTime.now.beginning_of_day
      errors.add(:starts_at, "Fra dato kan ikke være mer enn 9 måneder frem i tid.") if self.starts_at > 9.months.from_now
  end

  def validate_ends_at
      errors.add(:ends_at, "Til dato kan ikke være mer enn 1 år frem i tid.") if self.ends_at > 12.months.from_now
  end

  def validate_from_user_can_create_booking
    errors.add(:ends_at, "Du mangler en form for dokumentasjon for å gjennomføre denne handlingen.") unless self.from_user.can_rent? self.ad.category
  end

  def validate_deposit_offer_amount_less_than_or_equals_deposit_amount
    errors.add(:deposit_offer_amount, "Må være mindre enn depositum") if deposit_offer_amount > deposit_amount
  end


  # Comparable
  def <=>(other)
    if self.starts_at < other.starts_at
      -1
    elsif self.starts_at == other.starts_at and self.ends_at == other.ends_at
      0
    else
      1
    end
  end


  def to_param
    self.guid
  end

  def booking_calculator
    align_times # fixme: runeh: is this OK ? Need a way to ensure usable object without risking it being saved.
    BookingCalculator.new(ad: self.ad, starts_at: self.starts_at, ends_at: self.ends_at)
  end

  # Called from BookingCancelPreauthJob
  # Cancel all preauths connected to this booking.
  def cancel_all_financial_transaction_preauth!
    self.financial_transactions.preauth.processing_or_finished.map( &:process_cancel_preauth! )
    self.financial_transactions.preauth.pending.map( &:fail! )
  end

  # called from ???
  # refresh_status!
  def refresh!
    # if self.payment_preauthorized? || self.confirmed? || self.started? || self.archived?
    #   LOG.info "Not possible to refresh."
    # end

    if self.created?
      do_refresh_created!
    elsif self.confirmed?
      #do_refresh_confirmed!
    else
      LOG.info "Not possible to refresh."
      LOG.info message: "Nothing to do for this booking.", booking_id: self.id, booking_status: self.status
    end
  end




  private

  def create_financial_transaction_preauth
    preauth_financial_transaction = {
      purpose:          'rental_with_deposit',
      transaction_type: 'preauth',
      amount:   self.sum_paid_by_renter_with_deposit,
      fees:     0,
      src_type: :src_card_vid,
      src_vid:  self.from_user.user_payment_cards.find( user_payment_card_id ).card_vid
    }
    t = self.financial_transactions.create( preauth_financial_transaction )
    t.process!

    unless t.errored?
      self.secure_mode_needed       = t.secure_mode_needed
      self.secure_mode_redirect_url = t.secure_mode_redirect_url if t.secure_mode_needed
    end

    # we get the url to redirect the user to in secure_mode_redirect_url...
    # https://docs.mangopay.com/api-references/card/pre-authorization/
  end

  def create_financial_transaction_payin
    if self.financial_transactions.preauth.finished.present?
      preauth_transaction_vid  = self.financial_transactions.preauth.finished.take.transaction_vid

      raise "No valid preauth_transaction_vid in place" if preauth_transaction_vid.blank?
    else
      raise "No valid preauth_transaction_vid in place"
    end

    financial_transaction = {
      transaction_type: 'payin',
      purpose:  'rental_with_deposit',
      amount:   self.sum_paid_by_renter_with_deposit,
      fees:     0,
      src_type: :src_preauth_vid,
      src_vid:  preauth_transaction_vid
    }
    t = self.financial_transactions.create( financial_transaction )

    # called from a BookingProcessPayinJob:
    # processing payins takes around 30-40 seconds, so do it via a resque job
    #t.process!

    BookingProcessPayinJob.perform_later self
  end

  # Create payin_refunds for all payins connected to this booking which have finished status.
  def cancel_all_financial_transactions_payin
    self.financial_transactions.payin.finished.each do |ft|
      LOG.debug message: "found payin financial_transaction_id: #{ft.id} to refund (purpose: #{ft.purpose}", booking_id: self.id
      create_financial_transaction_refund_payin ft
    end
  end

  # Called from cancel_all_financial_transactions_payin above:
  def create_financial_transaction_refund_payin ft_to_refund
    financial_transaction = {
      transaction_type: 'payin_refund',
      purpose:  ft_to_refund.purpose,
      src_type: :src_payin_vid,
      src_vid:  ft_to_refund.transaction_vid
    }
    t = self.financial_transactions.create( financial_transaction )

    # called from a BookingProcessPayinRefundJob:
    # t.process!
    BookingProcessPayinRefundJob.perform_later self
  end

  # FIXME/NOTES(RA):
  # 2) At some point we should consider making IF a special customer, and making a split payment here.
  def create_financial_transaction_transfer_rental
    if self.financial_transactions.transfer.rental.finished.where( amount: self.sum_paid_by_renter, fees: self.sum_plaform_fee_and_insurance ).any?
      LOG.error message: "At least one identical sucessful financial_transaction exists. Will not create a duplicate one.", booking_id: self.id
      return false
    else
      # later we should make this a split payment!
      # NOTE: 'amount' will be automatically be deducted for the 'fees'
      financial_transaction = {
        transaction_type: 'transfer',
        purpose: 'rental',
        amount:  self.sum_paid_by_renter,
        fees:    self.sum_plaform_fee_and_insurance
      }
      t = self.financial_transactions.create( financial_transaction )

      # FIXME(RA): should be triggered from a job:
      t.process!
    end
  end

  def create_financial_transaction_transfer_deposit(transfer_deposit_amount = self.deposit_offer_amount)
    if transfer_deposit_amount > self.sum_deposit_available_for_refund
      LOG.error message: "Not possible to transfer more then what is available from the deposit.", booking_id: self.id
      # raise "TooLargeValueForTransferDepositAmount"
      return false
    else
      financial_transaction = {
        transaction_type: 'transfer',
        purpose: 'deposit',
        amount:  transfer_deposit_amount,
        fees:    0
      }
      t = self.financial_transactions.create( financial_transaction )

      # FIXME(RA): should be triggered from a job:
      t.process!
    end
  end

  # refund remaining deposit amount
  def create_financial_transaction_refund_deposit
    if self.sum_deposit_available_for_refund > 0
      financial_transaction = {
        transaction_type: 'payin_refund',
        purpose:  'deposit',
        amount:   self.sum_deposit_available_for_refund,
        fees:     0,
        src_type: :src_payin_vid,
        src_vid:  self.financial_transactions.payin.finished.take.transaction_vid
      }
      t = self.financial_transactions.create( financial_transaction )

      # FIXME(RA): should be triggered from a job:
      t.process!
    else
      LOG.error "Not possible to refund a negative value."
    end
  end

  # Refresh the booking status, given that it has the created status.
  def do_refresh_created!
    # refresh the preauth for this booking.
    ft = self.financial_transactions.preauth.take

    if ft.present? && ft.pending? || ft.processing?
      LOG.info message: "process_refresh! for ft", booking_id: self.id, financial_transaction_id: ft.id
      ft.process_refresh!
    end

    if ft.blank?
      LOG.error message: "All bookings need one preauth financial_transaction. " \
        "You are trying to refresh a booking without one. This is an error and " \
        "should never happen.", booking_id: self.id
    elsif ft.processing?
      LOG.info message: "preauth financial_transaction is still processing", booking_id: self.id
    elsif ft.pending?
      LOG.info message: "preauth financial_transaction is still pending", booking_id: self.id
    elsif ft.errored? || ft.unknown_state?
      # set booking to failed preauthoration status.
      self.payment_preauthorization_fail!

    elsif ft.finished? #&& ft.preauth_waiting?
      # Preauth is ready to be charged! Once the « PreAuthorization » object gets
      #  "Status" = "SUCCEEDED" and "PaymentStatus" = "WAITING" you can charge the card.
      # See: https://docs.mangopay.com/api-references/payins/preauthorized-payin/
      LOG.error message: "preauth financial_transaction does not " \
        " have preauth_payment_status: preauth_waiting" unless ft.preauth_waiting?

      self.payment_preauthorize!
    end

    LOG.info message: "Booking now has status: #{self.status}", booking_id: self.id
  end

  # Refresh the booking status, given that it has the confirmed status.
  def do_refresh_confirmed!
  end


  # When a booking is created, the starts_at and ends_at
  #  have a pre-determined timepoint. We enforce it in this callback
  #  method that is called only on create.
  def align_times
    # if booking the same day, then starts_at is in one minute from now.
    earliest_possible_starts_at = ( self.starts_at.to_date == Date.today ) ? ( DateTime.now + 1.minute ) : self.starts_at.beginning_of_day
    self.attributes = {
      starts_at: earliest_possible_starts_at,
      ends_at:   self.ends_at.end_of_day
    }
  end

  def set_guid
    self.guid = loop do
      # for a shorter string use:
      # generated_guid = SecureRandom.random_number(2**122).to_s(36)
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end

end