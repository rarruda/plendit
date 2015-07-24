class AdItem < ActiveRecord::Base
  belongs_to :ad
  has_many :bookings


 def availability_for_month( year = Date.today.year , month = Date.today.month )
    #AVAILABILITY_STATUSES = ['booked', 'starting', 'ending', 'available'] #'past', 'today'

    ##correct:
    bookings = Booking.active.ad_item( self.id ).exclude_past.in_month(year,month).order( :starts_at )
    # needs to have 'active', otherwise we show unconfirmed bookings as fully booked.
    # FOR debugging:
    #bookings = Booking.ad_item( self.id ).exclude_past.in_month(year,month).order( :starts_at )
    # logger.debug pp bookings

    availability_cal = {}

    ( Date.new(year,month).beginning_of_month ... Date.new(year,month).end_of_month ).each do |d|
      if d.past?
        availability_cal[d.day] = 'past'
      elsif d == Date.today
        # FIXME: Today is totally broken. we probably want to have that in adition of whatever other status we have:
        availability_cal[d.day] = 'today'
      else
        availability_cal[d.day] = 'available'
        # TODO: Optimize. no need to loop over all bookings on every date.
        bookings.each { |b|
          if availability_cal[d.day] == 'available'
            availability_cal[d.day] = b.date_status(d)
          end
        }
      end
    end

    availability_cal
  end

end
