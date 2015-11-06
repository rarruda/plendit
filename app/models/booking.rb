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
  has_many :transactions

  enum status: { created: 0, accepted: 1, cancelled: 2, declined: 3 }

  #default_scope { where( status: active ) }

  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  scope :current,    -> { where( 'status' => [ self.statuses[:created], self.statuses[:accepted] ] ) }
  scope :active,     -> { where( status: accepted ) }
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
    state :created, :initial => true
    state :accepted #, :enter => :trigger_notification, :exit => :trigger_notification
    state :cancelled
    state :declined #, :enter => :trigger_notification
    state :started
    state :finished #can review and create a skademelding
    #   after 48 hours it got to finished:
    #state :closed #can review, but not create a skademelding
    #   after 7 days it got to finished:
    #state :closed_shut #can neither review nor create a skademelding

    #on created:
      #mangopay.payment_preauth_create
    # end


    event :accept do
      transitions :from => [:created,:declined], :to => :accepted
      #mangopay.payment_payin_from_preauth
    end
    event :cancel do
      transitions :from => :created, :to => :cancelled
      # only if current_user.id != user.id
      #mangopay.payment_transfer
    end
    event :decline do
      transitions :from => [:created,:accepted], :to => :declined
      #mangopay.payment_preauth________foobar__refund
    end
    event :start do
      transitions :from => :accepted, :to => :started
      # 2 days later: mangopay.payment_transfer
    end
    event :finish do
      transitions :from => :started, :to => :finished
    end
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
