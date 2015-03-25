class Feedback < ActiveRecord::Base
  belongs_to :ad
  has_one :profile, :through => :ad
  has_one :from_profile, :class_name => "Profile"
  #has_one :from_profile, :foreign_key => "from_profile_id", :class_name => "Profile"
end
