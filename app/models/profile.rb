class Profile < ActiveRecord::Base
  has_many :ads, dependent: :destroy
  has_many :ad_items, :through => :ads

  # received_bookings == bookings:
  has_many :bookings, :through => :ad_items
  has_many :sent_bookings, foreign_key: 'from_profile_id', :class_name => "Booking"

  has_many :received_feedbacks, :through => :ads, :class_name => "Feedback"
  has_many :sent_feedbacks, foreign_key: 'from_profile_id', :class_name => "Feedback"

  belongs_to :profile_status

  has_many :received_messages, foreign_key: 'to_profile_id', :class_name => "Message"
  has_many :sent_messages, foreign_key: 'from_profile_id', :class_name => "Message"
end
