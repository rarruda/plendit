class Booking < ActiveRecord::Base
  include Comparable
  include AASM

  extend TimeSplitter::Accessors

  has_paper_trail

  split_accessor :starts_at
  split_accessor :ends_at

  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"
  belongs_to :user_payment_card

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages
  has_many :transactions, as: 'transactionable'


  enum status: { created: 0, confirmed: 1, started: 2, in_progress: 3, ended: 4, archived: 5, aborted: 10, cancelled: 11, declined: 12, admin_paused: 99 }

  #default_scope { where( status: active ) }

  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  scope :current,    -> { where( 'status' => [ self.statuses[:created], self.statuses[:confirmed], self.statuses[:started], self.statuses[:in_progress], self.statuses[:ended] ] ) }
  scope :active,     -> { where( 'status' => [ self.statuses[:started], self.statuses[:in_progress] ] ) }
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
  validates_uniqueness_of :guid

  validates :ad_item_id, :presence => true
  validates :from_user_id, :presence => true
  validates :user_payment_card_id, :presence => true

  validates :amount, numericality: { greater_than:  100_00, message: "must be at least 100 kr"}
  validates :amount, numericality: { less_than: 150_000_00, message: "must be at less then 150.000 kr"}
  #validates :amount, numericality: { less_than:  25_000_00, message: "must be at less then  25.000 kr"}, if: "false" #KYC not provisioned

  validate :validate_user_payment_card_belongs_to_from_user


  before_validation :set_guid, :on => :create
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
    if: :payout_amount_changed?,
    if: :insured_changed?



  aasm :column => :status, :enum => true do
    state :created, :initial => true #, :enter => create_transaction_preauth
    state :confirmed
    state :started
    state :in_progress
    state :ended
    state :archived

    state :aborted
    state :cancelled
    state :declined

    state :admin_paused

    #after_all_transitions :log_status_change

    event :confirm do
    #, after: :create_transaction_payin do
      transitions :from => :created, :to => :confirmed

      after do
        LOG.info "capture preauth payin... (dummy only)", booking_id: self.id
        #self.create_transaction_payin
      end
    end

    event :abort do
      transitions :from => :created, :to => :aborted

      # only if current_user.id == from_user.id
      after do
        LOG.info "refund preauth payin... (dummy only)", booking_id: self.id
        #self.transactions.preauth.finished.each { |t| t.process_cancel_preauth }
      end
    end

    event :decline do
      transitions :from => :created, :to => :declined

      # only if current_user.id == user.id
      after do
        LOG.info "refund refund preauth payin... (dummy only)", booking_id: self.id
        #self.transactions.preauth.finished.each { |t| t.process_cancel_preauth }
      end
    end

    event :cancel do
      transitions :from => [:confirmed,:started], :to => :cancelled do
        guard do
          # if started, can still cancel within 24hours.
          self.started? && ( self.starts_at + 1.day < DateTime.now )
        end
      end

      after do
        LOG.info "refund transfer or refund_payin... (dummy only)", booking_id: self.id
        #refund transfer or refund_payin
        #Resque.enque( foobar_JOB_mangopay_payment_transfer____refund_payin? )
      end
    end

    event :start do
      transitions :from => :confirmed, :to => :started

      after do
        LOG.info "schedule auto-set_in_progress as new status in 1.day... (dummy only)", booking_id: self.id
        #Resque.enqueue_in( (self.starts_at + 1.day), foobar_JOB_transition_to_in_progress )
      end
    end

    event :set_in_progress do
      transitions :from => :started, :to => :in_progress

      after do
        LOG.info "make transfer of funds... (dummy only)", booking_id: self.id
        #self.create_transaction_transfer

        LOG.info "schedule auto-end at ends_at(#{self.ends_at})... (dummy only)", booking_id: self.id
        #Resque.enqueue_in( (self.ends_at), foobar_JOB_transition_to_end )
      end
    end

    event :end do
      transitions :from => :in_progress, :to => :ended
      after do
        LOG.info "schedule auto-archival in 7 days.", booking_id: self.id
        #Resque.enqueue_in( (self.ends_at + 7.days), foobar_JOB_transition_to_archive )
      end
    end

    event :archive do
      transitions :from => :ended, :to => :archived
    end

    # dont do anything. when manual intervention is required/exception handling:
    # this is a tar-pit state.
    event :admin_pause do
      transitions :from => [:confirmed, :started, :in_progress, :ended], :to => :admin_paused
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
    LOG.info "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
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




  def create_transaction_preauth
    transaction = {
      transaction_type: 'preauth',
      amount: self.sum_paid_by_renter,
      fees:   0,
    }
    t = self.transaction.create( transaction )
    t.process!
  end

  def create_transaction_payin
    transaction = {
      transaction_type: 'payin',
      amount:   self.sum_paid_by_renter,
      fees:     0,
      #FIXME: values below seem to get overwritten in transaction model
      src_type: :src_preauth_vid,
      src_vid:  self.transactions.preauth.finished.take.transaction_vid
    }
    t = self.transaction.create( transaction )
    t.process!
  end

  def cancel_transaction_preauth
    self.transactions.preauth.finished.take.process_cancel_preauth
  end


  def create_transaction_transfer
    # later we should make this a split payment!
    transaction = {
      transaction_type: 'transfer',
      amount: self.sum_paid_to_owner,
      fees:   self.sum_plaform_fee_and_insurance
    }
    t = self.transaction.create( transaction )
    t.process!
  end





  # FIXME: temporarely in place just during a transition period.
  #  to be removed.
  def amount
    self.payout_amount
  end

  def calculate_amount
    ####self.amount = self.duration_in_days * self.ad.price
    self.payout_amount = self.booking_calculator.payin_amount
  end

  def calculate_fee
    ####self.platform_fee_amount = ( self.amount * Plendit::Application.config.x.platform.fee_in_percent ).to_i
    self.platform_fee_amount = self.booking_calculator.platform_fee
  end

  def calculate_insurance
    self.insurance_amount = self.booking_calculator.insurance_fee
  end

  def sum_paid_to_owner
    ##self.amount
    self.payout_amount
  end

  def sum_paid_by_renter
    ##( self.amount + self.platform_fee_amount + self.insurance_amount )
    self.payout_amount + self.platform_fee_amount + self.insurance_amount
  end

  def sum_plaform_fee_and_insurance
    ( self.platform_fee_amount + self.insurance_amount )
  end

  # duration_in_days rounded up for fractions of a day.
  #  Minimum duration of one day.
  #def duration_in_days
  #  d = ( (self.ends_at - self.starts_at) / 1.day.to_i  ).ceil
  #  raise "You cant have a negative duration for a booking" if d < 0
  #
  #  d == 0 ? 1 : d
  #end


  def last_preauthorization_vid
    # should be ordered by id first...
    self.transactions.preauth.last.transaction_vid
  end

  ###
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
    if self.from_user.user_payment_cards.find( self.user_payment_card_id ).blank?
      errors.add(:user_payment_card, "card must belong to from_user")
    end
  end

  def validate_starts_at_before_ends_at
      errors.add(:ends_at, "ends_at cannot be before starts_at") if self.ends_at < self.starts_at
  end

  def validate_starts_at
      errors.add(:starts_at, "starts_at cannot be in the past") if self.starts_at < DateTime.now
      errors.add(:starts_at, "starts_at cannot be over 9 months in the future") if self.starts_at > 9.months.from_now
  end

  def validate_ends_at
      errors.add(:ends_at, "ends_at cannot be over one year in the future") if self.ends_at > 12.months.from_now
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

  # compare it with a date?
  # TODO: consider merging with the comparable between bookings above.
  #def <=>(date)
  #  if self.ends_at.date < date
  #    -1
  #  elsif date >= self.starts_at.date and date <= self.ends_at.date
  #    0
  #  else
  #    1
  #  end
  #end


  def to_param
    self.guid
  end

  def booking_calculator
    BookingCalculator.new(ad: self.ad, starts_at: self.starts_at, ends_at: self.ends_at)
  end

  private

  def set_guid
    self.guid = loop do
      # for a shorter string use:
      #generated_guid = SecureRandom.random_number(2**122).to_s(36)
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end

end
