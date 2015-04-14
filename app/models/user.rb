class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable ###, :omniauthable, omniauth_providers: [:facebook]
  has_many :ads, dependent: :destroy
  has_many :ad_items, :through => :ads

  # received_bookings == bookings:
  has_many :bookings, :through => :ad_items
  has_many :sent_bookings, foreign_key: 'from_user_id', :class_name => "Booking"

  has_many :received_feedbacks, :through => :ads, :class_name => "Feedback"
  has_many :sent_feedbacks, foreign_key: 'from_user_id', :class_name => "Feedback"

  belongs_to :user_status

  has_many :received_messages, foreign_key: 'to_user_id', :class_name => "Message"
  has_many :sent_messages, foreign_key: 'from_user_id', :class_name => "Message"

  validates :name, presence: true
  validates :phone_number, presence: true, format: { with: /\A[0-9]{8}\z/, message: "only allows numbers" }
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "valid email required" }


  def calculate_average_rating
    if self.received_feedbacks.size == 0
      return 0
    end

    i   = 0
    sum = 0
    self.received_feedbacks.each do |fb|
      i   += 1
      sum += fb.score
    end
    ( sum / i )
  end

end
