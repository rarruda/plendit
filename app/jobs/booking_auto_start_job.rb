class BookingAutoStartJob < ActiveJob::Base
  queue_as :default

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoStartJob"

    if booking.payment_confirmed?
      booking.start!
      puts "booking_id:#{booking.id} has now status: #{booking.status}"
    else
      puts "ERROR: can not start a booking, as it is not payment_confirmed. current status: #{booking.status} for booking_id:#{booking.id}."
    end

    puts "#{DateTime.now.iso8601} Ending BookingAutoStartJob for #{booking.id}"
  end
end
