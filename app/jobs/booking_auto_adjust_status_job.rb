class BookingAutoAdjustStatusJob < ActiveJob::Base
  queue_as :low

  def perform
    puts "#{DateTime.now.iso8601} Starting BookingAutoAdjustStatusJob"

    puts "Bump booking statuses which could be wrong... interate over all bookings with current statuses:"
    Booking.all.where( status: [ self.statuses[:payment_confirmed], self.statuses[:started],
                                 self.statuses[:in_progress], self.statuses[:ended] ] ).each do |b|

      if b.payment_confirmed? && b.should_be_started?
        puts "#{DateTime.now.iso8601} - bumping payment_confirmed, which should have been started already - booking_id:#{b.id}"
        b.start!
      end
      if b.started? && b.should_be_in_progress?
        puts "#{DateTime.now.iso8601} - bumping started, which should have been in_progress already - booking_id:#{b.id}"
        b.set_in_progress!
      end
      if b.in_progress? && b.should_be_ended?
        puts "#{DateTime.now.iso8601} - bumping in_progress, which should have been ended already - booking_id:#{b.id}"
        b.end!
      end
      if b.ended? && b.should_be_archived?
        puts "#{DateTime.now.iso8601} - bumping ended, which should have been archived already - booking_id:#{b.id}"
        b.archive!
      end

      unless b.changed?
        puts "#{DateTime.now.iso8601} - DEBUG: nothing to do - booking_id:#{b.id} - status: #{b.status}"
      end
    end

    puts "#{DateTime.now.iso8601} Ending BookingAutoAdjustStatusJob"
  end
end
