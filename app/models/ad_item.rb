class AdItem < ActiveRecord::Base
  belongs_to :ad
  has_many :bookings #, dependent: :nullify

  def unavailability
    bookings = Booking.reserved.ad_item( self.id ).order( :starts_at )
    bookings.map { |b| (b.starts_at.to_date..b.ends_at.to_date).to_a }.flatten
  end

end
