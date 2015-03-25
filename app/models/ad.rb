class Ad < ActiveRecord::Base
  belongs_to :profile
  has_many :feedbacks
end
