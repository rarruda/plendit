class Profile < ActiveRecord::Base
  has_many :ads, dependent: :destroy
  #has_many :received_feedbacks, :through => :ad, foreign_key: 'profile_id', :class_name => "Feedback"
  has_many :received_feedbacks, :through => :ad, :class_name => "Feedback"
  has_many :sent_feedbacks, foreign_key: 'from_profile_id', :class_name => "Feedback"
end
