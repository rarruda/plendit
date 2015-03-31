class Ad < ActiveRecord::Base
  belongs_to :profile
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
end
