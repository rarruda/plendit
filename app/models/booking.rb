class Booking < ActiveRecord::Base
  extend TimeSplitter::Accessors

  split_accessor :booking_from
  split_accessor :booking_to

  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

  enum status: { created: 0, accepted: 1, declined: 2, declined: 3 }

  scope :owner_user, ->(user) { joins(:ad).where( 'ads.user_id = ?', user.id ) }
  scope :from_user,  ->(user) { where( from_user_id: user.id ) }

  # fixme: real data for this, and something like .humanize on the prices

  def sum_paid_to_owner
    self.price * 0.9
  end

  def sum_paid_by_renter
    self.price
  end

  def duration_in_days
    (self.booking_to.to_date - booking_from.to_date).to_i
  end

end
