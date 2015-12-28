class BookingAutoSetInProgressJob < ActiveJob::Base
  queue_as :high

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoSetInProgressJob"

    if booking.started?
      booking.set_in_progress!
      puts "booking_id:#{booking.id} has now status: #{booking.status}"
    else
      puts "ERROR: can not start a booking, as it is not started. current status: #{booking.status} for booking_id:#{booking.id}."
    end

    puts "#{DateTime.now.iso8601} Ending BookingAutoSetInProgressJob for #{booking.id}"
  end
end
