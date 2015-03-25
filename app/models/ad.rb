class Ad < ActiveRecord::Base
  belongs_to :profile
  has_many :feedbacks
  has_many :ad_items
end
