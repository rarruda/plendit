class AdItem < ActiveRecord::Base
  belongs_to :ad
  has_many :bookings
end
