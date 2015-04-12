class Ad < ActiveRecord::Base
  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
end
