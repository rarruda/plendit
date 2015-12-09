class Feedback < ActiveRecord::Base
  belongs_to :booking
  belongs_to :from_user, :class_name => "User"
  has_one :user, :through => :booking

  validates :score, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :body, presence: true, length: { in: 5..2048 }
end
