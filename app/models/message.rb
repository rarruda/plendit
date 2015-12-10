class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :from_user,   class_name: "User"
  belongs_to :to_user,     class_name: "User"
  has_many :notifications, as: :notifiable, dependent: :destroy
end
