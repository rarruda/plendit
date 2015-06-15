class Booking < ActiveRecord::Base
  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

  enum status: { created: 0, accepted: 1, declined: 2, declined: 3 }


  # fixme: real data for this, and something like .humanize on the prices

  def sum_paid_to_owner
    self.price * 0.9
  end

  def sum_paid_by_renter
    self.price
  end

end
