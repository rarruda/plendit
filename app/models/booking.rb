class Booking < ActiveRecord::Base
  belongs_to :ad_item
  belongs_to :from_user, :class_name => "User"

  has_one :ad, through: :ad_item
  has_one :user, through: :ad
  has_many :messages

  belongs_to :booking_status
end
