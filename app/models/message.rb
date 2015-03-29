class Message < ActiveRecord::Base
  belongs_to :booking
  has_one :from_profile, :class_name => "Profile"
  has_one :to_profile,   :class_name => "Profile"
end
