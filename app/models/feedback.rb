class Feedback < ActiveRecord::Base
  belongs_to :ad
  belongs_to :from_user, :class_name => "User"
  has_one :user, :through => :ad
end
