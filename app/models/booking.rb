class Booking < ActiveRecord::Base
  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

  belongs_to :booking_status

  # fixme: real data for this, and something like .humanize on the prices

  def sum_paid_to_owner
    260
  end

  def sum_paid_by_renter
    300
  end

end
