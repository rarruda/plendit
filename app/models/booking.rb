class Booking < ActiveRecord::Base
  belongs_to :ad_item
  has_one :booking_status
  has_one :from_profile, :class_name => "Profile"
  #has_one :from_profile, :foreign_key => "from_profile_id", :class_name => "Profile"
end
