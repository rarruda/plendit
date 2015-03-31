class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :from_profile, :class_name => "Profile"
  belongs_to :to_profile,   :class_name => "Profile"
end
