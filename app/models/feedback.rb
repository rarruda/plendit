class Feedback < ActiveRecord::Base
  belongs_to :ad
  belongs_to :from_profile, :class_name => "Profile"
  has_one :profile, :through => :ad
end
