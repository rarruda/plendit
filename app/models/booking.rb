class Booking < ActiveRecord::Base
  include Comparable

  extend TimeSplitter::Accessors

  split_accessor :starts_at
  split_accessor :ends_at

  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

  enum status: { created: 0, accepted: 1, declined: 2, declined: 3 }

  #default_scope { where( status: active ) }

  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  scope :active,     -> { where( status: accepted ) }
  scope :ad_item,    ->(ad_item_id) { where( ad_item_id: ad_item_id ) }
  scope :in_month,   ->(year,month) { where( 'ends_at >= ? and starts_at <= ?',
    DateTime.new(year, month).beginning_of_month, DateTime.new(year, month).end_of_month ) }

  scope :exclude_past,   ->{ where( 'ends_at >= ?', DateTime.now ) }


  validates :starts_at, :ends_at, :overlap => {
    :scope         => "ad_item_id",
    :query_options => { :active => nil }
  }

  # fixme: real data for this, and something like .humanize on the prices
  def calculate_price
    self.price = self.duration_in_days * self.ad.price
  end

  def sum_paid_to_owner
    self.price * 0.88
  end

  def sum_paid_by_renter
    self.price
  end

  def duration_in_days
    (self.ends_at.to_date - starts_at.to_date).to_i
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

  # copare it with a date?
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

end
