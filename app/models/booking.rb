class Booking < ActiveRecord::Base
  include Comparable
  include AASM

  extend TimeSplitter::Accessors

  has_paper_trail

  split_accessor :starts_at
  split_accessor :ends_at

  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

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
  validates_uniqueness_of :guid

  validates :ad_item_id, :presence => true
  validates :from_user_id, :presence => true

  #validates_numericality_of :amount,
  #  greater_than: 500,
  #  message: "must be at least 5 kroner"

  before_validation :set_guid, :on => :create
  before_save :calculate_amount,
    if: :starts_at_changed?,
    if: :ends_at_changed?



  aasm :column => :status, :enum => true do
    state :created, :initial => true
    state :accepted #, :enter => :trigger_notification, :exit => :trigger_notification
    state :cancelled
    state :declined #, :enter => :trigger_notification

    event :accept do
      transitions :from => [:created,:declined], :to => :accepted
    end
    event :cancel do
      transitions :from => :created, :to => :cancelled
      # only if current_user.id != user.id
    end
    event :decline do
      transitions :from => [:created,:accepted], :to => :declined
    end
  end



  # fixme: real data for this, and something like .humanize on the prices/amounts
  # fixme: add booking_item for VAT, platform_fees(us), insurance, etc.
  def calculate_amount
    #platform_fee_pct  = Plendit::Application.config.x.platform.fee_in_percent
    #insurance_fee_pct = Plendit::Application.config.x.insurance.price_in_percent
    #mva?

    self.amount = self.duration_in_days * self.ad.price
  end

  def sum_paid_to_owner
    self.amount * 0.88
  end

  def sum_paid_by_renter
    self.amount
  end

  # duration_in_days rounded up for fractions of a day.
  #  Minimum duration of one day.
  def duration_in_days
    d = ( (self.ends_at - self.starts_at) / 1.day.to_i  ).ceil
    raise "You cant have a negative duration for a booking" if d < 0

    d == 0 ? 1 : d
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


  def validate_starts_at_before_ends_at
      errors.add(:ends_at, "ends_at cannot be before starts_at") if self.ends_at < self.starts_at
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
