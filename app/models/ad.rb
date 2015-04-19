class Ad < ActiveRecord::Base
  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
  belongs_to :location


  validates :title, presence: true, length: { in: 3..255 }
  validates :body,  presence: true
  validates :user,  presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  #validates :location, presence: true
end
