class Booking < ActiveRecord::Base
  include Comparable
  include AASM

  extend TimeSplitter::Accessors

  has_paper_trail

  split_accessor :starts_at
  split_accessor :ends_at

  belongs_to :ad_item
  belongs_to :from_user,      class_name: "User"
  belongs_to :user_payment_card

  has_one :ad,                through: :ad_item
  has_one :user,              through: :ad
  has_many :feedbacks,        dependent: :destroy
  has_many :messages,         dependent: :destroy
  has_many :accident_reports, dependent: :destroy
  has_many :financial_transactions, as: 'financial_transactionable', dependent: :nullify #:restrict_with_exception

  enum status: { created: 0, confirmed: 1, started: 2, in_progress: 3, ended: 4, archived: 5, aborted: 10, cancelled: 11, declined: 12, disputed: 15, admin_paused: 99 }

  #default_scope { where( status: active ) }

  scope :has_user,   ->(user) { joins(:ad).where( 'from_user_id = ? OR ads.user_id = ? ', user.id, user.id ) }
  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  scope :accidents_reportable,
                     -> { where( 'status' => [ self.statuses[:started], self.statuses[:in_progress], self.statuses[:ended] ] ) }
  scope :current,    -> { where( 'status' => [ self.statuses[:created], self.statuses[:confirmed], self.statuses[:started], self.statuses[:in_progress], self.statuses[:ended] ] ) }
  scope :active,     -> { where( 'status' => [ self.statuses[:started], self.statuses[:in_progress] ] ) }
  scope :reserved,   -> { where( 'status' => [ self.statuses[:confirmed], self.statuses[:started], self.statuses[:in_progress] ] ) }
  scope :ad_item,    ->(ad_item_id) { where( ad_item_id: ad_item_id ) }
  scope :in_month,   ->(year,month) { where( 'ends_at >= ? and starts_at <= ?',
    DateTime.new(year, month).beginning_of_month, DateTime.new(year, month).end_of_month ) }
  scope :in_between, ->(start_date,end_date) { where( 'ends_at >= ? and starts_at <= ?', start_date, end_date) }

  scope :exclude_past,   ->{ where( 'ends_at >= ?', DateTime.now ) }



  validates :starts_at, :ends_at, :overlap => {
    :scope         => "ad_item_id",
    :query_options => { :active => nil }
  }
  validate :validate_starts_at_before_ends_at
  validate :validate_starts_at
  validate :validate_ends_at

  validates :guid,                 uniqueness: true
  validates :ad_item_id,           presence: true
  validates :from_user_id,         presence: true
  validates :user_payment_card_id, presence: true
  validates :amount,               numericality: { greater_than_or_equals: 99_00, message: "Må være minst 99kr"}
  validates :amount,               numericality: { less_than:         150_000_00, message: "Kan ikke være mer enn 150.000 kroner"}
  #validates :amount, numericality: { less_than:  25_000_00, message: "must be at less then  25.000 kr"}, if: "false" #KYC not provisioned

  validate :validate_user_payment_card_belongs_to_from_user

  # write validation to check that the from_user has enough id
  # to be able to create a valid booking:
  validate :validate_from_user_can_create_booking


  before_validation :align_times, on: :create
  before_validation :set_guid,    on: :create
  before_validation :calculate_amount,
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

  after_create :send_mail_booking_created

  aasm :column => :status, :enum => true do
    state :created, :initial => true
    state :confirmed
    state :started
    state :in_progress
    state :ended
    state :archived

    state :aborted
    state :cancelled
    state :declined
    state :disputed

    state :admin_paused

    after_all_transitions :log_status_change

    event :confirm do
      transitions from: :created, to: :confirmed
      after do
        # FIXME?: check if no transactions exist already?
        create_financial_transaction_payin
        BookingAutoStartJob.set(wait_until: self.starts_at ).perform_later self

        # old booking mailer:
        send_confirmations
        # new mailer:
        message = ApplicationMailer.booking_confirmed__to_owner( self )
        message.deliver_later

        message = ApplicationMailer.booking_confirmed__to_renter( self )
        message.deliver_later
      end
    end

    event :abort, after: :cancel_financial_transaction_preauth do
      transitions from: :created, to: :aborted
    end

    event :decline, after: :cancel_financial_transaction_preauth do
      transitions from: :created, to: :declined
      after do
        message = ApplicationMailer.booking_declined__to_renter( self )
        message.deliver_later
      end
    end

    event :dispute do
      transitions from: :started, to: :disputed
    end

    #after: :refund_payin
    event :cancel do
      transitions from: [:confirmed,:started], to: :cancelled do
        guard do
          # confirmed or if started, can still cancel within 24hours.
          self.confirmed? || ( self.started? && ( self.starts_at + 1.day < DateTime.now ) )
        end
      end
      after do
        cancel_financial_transaction_payin

        message = ApplicationMailer.booking_cancelled( self )
        message.deliver_later
      end
    end

    event :start do
      transitions from: :confirmed, to: :started

      after do
        LOG.info "schedule auto-set_in_progress as new status in 1.day...", booking_id: self.id
        BookingAutoSetInProgressJob.set(wait_until: (self.starts_at + 1.day) ).perform_later self
      end
    end

    event :set_in_progress, after: :create_financial_transaction_transfer do
      transitions from: :started, to: :in_progress

      after do
        LOG.info "make transfer of funds...", booking_id: self.id
        create_financial_transaction_transfer
        LOG.info "schedule auto-end at ends_at(#{self.ends_at})...", booking_id: self.id
        BookingAutoEndJob.set(wait_until: self.ends_at ).perform_later self
      end
    end

    event :end do
      transitions from: :in_progress, to: :ended
      after do
        LOG.info "schedule auto-archival 7 days after ends_at.", booking_id: self.id
        BookingAutoArchiveJob.set(wait_until: (self.ends_at + 7.days + 1.second) ).perform_later self
      end
    end

    event :archive do
      transitions from: :ended, to: :archived
      # UserFeedbackScoreRefreshAllJob should run daily for all users,
      #  so no need to trigger it again here.
      #after do
      #  UserFeedbackScoreRefreshJob.set(wait: 1.hour).perform_later self.to_user_id
      #end
    end

    # dont do anything. when manual intervention is required/exception handling:
    # tar-pit state.
    event :admin_pause do
      transitions from: [:created,:confirmed, :started, :in_progress, :ended], to: :admin_paused
    end
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
    # after ended, can give feedback
    self.ended? #|| ( self.ends_at + 7.days ) < DateTime.now
  end

  def log_status_change
    LOG.info "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event}) for booking_id: #{self.id}"
  end

  def should_be_in_progress?
    self.started && ( ( self.starts_at + 1.day ) > DateTime.now )
  end

  def should_be_ended?
    self.in_progress && ( ( self.ends_at ) > DateTime.now )
  end

  def should_be_archived?
    self.ended && ( ( self.ends_at + 7.days ) > DateTime.now )
  end

  def was_ever_confirmed?
    [
      self.confirmed?, self.disputed?, self.started?, self.in_progress?,
      self.ended?, self.archived?, self.aborted?
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

  def calculate_amount
    self.payout_amount = self.booking_calculator.payin_amount
  end

  def calculate_fee
    self.platform_fee_amount = self.booking_calculator.platform_fee
  end

  def calculate_insurance
    self.insurance_amount = self.booking_calculator.insurance_fee
  end

  def sum_paid_to_owner
    self.payout_amount
  end

  def sum_paid_by_renter
    self.payout_amount + self.platform_fee_amount + self.insurance_amount
  end

  def sum_paid_by_renter_per_day
    (self.payout_amount + self.platform_fee_amount + self.insurance_amount) / self.days
  end

  def sum_plaform_fee_and_insurance
    ( self.platform_fee_amount + self.insurance_amount )
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
    if self.from_user.user_payment_cards.find_by( id: self.user_payment_card_id ).blank?
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


  private

  def send_mail_booking_created
    message = ApplicationMailer.booking_created__to_owner( self )
    message.deliver_later
  end

  def send_confirmations
    LOG.info "owner_accepted email:"
    message = BookingMailer.notify_owner_accepted( self.id )
    message.deliver_later

    LOG.info "renter_accepted email:"
    message = BookingMailer.notify_renter_accepted( self.id )
    message.deliver_later
  end

  def create_financial_transaction_preauth
    financial_transaction = {
      transaction_type: 'preauth',
      amount:   self.sum_paid_by_renter,
      fees:     0,
      src_type: :src_card_vid,
      src_vid:  self.from_user.user_payment_cards.find( user_payment_card_id ).card_vid
    }
    t = self.financial_transactions.create( financial_transaction )
    t.process!
  end

  def create_financial_transaction_payin
    if self.financial_transactions.preauth.finished.present?
      preauth_transaction_vid = self.financial_transactions.preauth.finished.take.transaction_vid
      raise "No valid preauth_transaction_vid in place" if preauth_transaction_vid.blank?
    else
      raise "No valid preauth_transaction in place" if preauth_transaction_vid.blank?
    end

    financial_transaction = {
      transaction_type: 'payin',
      amount:   self.sum_paid_by_renter,
      fees:     0,
      src_type: :src_preauth_vid,
      src_vid:  preauth_transaction_vid
    }
    t = self.financial_transactions.create( financial_transaction )
    t.process!
  end

  def cancel_financial_transaction_preauth
    self.financial_transactions.preauth.finished.map( &:process_cancel_preauth! )
  end

  def cancel_financial_transaction_payin
    # NOT IN PLACE! PAYINS ARE NOT (YET) REFUNDABLE
    # OR WILL IT BE CREATING A REFUND??
    ##self.financial_transactions.payin.pending_or_processing.map( &:process_cancel_payin! )
  end


  def create_financial_transaction_transfer
    # later we should make this a split payment!
    # NOTE: 'amount' will be automatically be deducted for the 'fees'
    financial_transaction = {
      transaction_type: 'transfer',
      amount: self.sum_paid_by_renter,
      fees:   self.sum_plaform_fee_and_insurance
    }
    t = self.financial_transactions.create( financial_transaction )
    t.process!
  end

  # When a booking is created, the starts_at and ends_at
  #  have a pre-determined timepoint. We enforce it in this callback
  #  method that is called only on create.
  def align_times
    self.attributes = {
      starts_at: self.starts_at.beginning_of_day,
      ends_at:   self.ends_at.end_of_day
    }
  end

  def set_guid
    self.guid = loop do
      # for a shorter string use:
      #generated_guid = SecureRandom.random_number(2**122).to_s(36)
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end

end