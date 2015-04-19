class Feedback < ActiveRecord::Base
  belongs_to :ad
  belongs_to :from_user, :class_name => "User"
  has_one :user, :through => :ad

  validates :body, presence: true, length: { in: 5..2048 }
end
