class BookingStatus < ActiveRecord::Base
  has_many :bookings
end
