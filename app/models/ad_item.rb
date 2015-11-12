class AdItem < ActiveRecord::Base
  belongs_to :ad
  has_many :bookings


 def availability_for_month( year = Date.today.year , month = Date.today.month )
    #AVAILABILITY_STATUSES = ['booked', 'starting', 'ending', 'available'] #'past', 'today'

    ##correct:
    bookings = Booking.active.ad_item( self.id ).exclude_past.in_month(year,month).order( :starts_at )
    # FOR debugging:
    #bookings = Booking.ad_item( self.id ).exclude_past.in_month(year,month).order( :starts_at )
    # LOG.debug pp bookings

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

  # Returns dates which there is a full day worth of bookings already in place.
  # by default it will do for just the current month
  # FIXME: ignores partially available days
  def unavailability( start_year = Date.today.year , start_month = Date.today.month, end_year = Date.today.next_month.year, end_month = Date.today.next_month.month )
    bookings = Booking.active.ad_item( self.id ).exclude_past.in_between( DateTime.new(start_year, start_month).beginning_of_month, DateTime.new(end_year, end_month).end_of_month ).order( :starts_at )

    unavailable_dates = []
    ( Date.new(start_year,start_month).beginning_of_month ... Date.new(end_year,end_month).end_of_month ).each do |d|
      next if d.past?
      bookings.each { |b|
        #next if b.date_status(d) == 'available'
        unavailable_dates << d if b.date_status(d) == 'booked'
      }
    end

    #availability_cal
    unavailable_dates
  end
end
