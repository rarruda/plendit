class Booking < ActiveRecord::Base
  belongs_to :ad_item
  belongs_to :from_profile, :class_name => "Profile"
  has_one :ad, through: :ad_item
  has_one :profile, through: :ad
  has_many :messages

  has_one :booking_status
end
