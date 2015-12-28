class BookingAutoEndJob < ActiveJob::Base
  queue_as :high

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoEndJob for #{booking.id}"

    if booking.in_progress?
      booking.end!
      puts "booking_id:#{booking.id} has now status: #{booking.status}"
    else
      puts "ERROR: can not end a booking, as it is not in_progress. current status: #{booking.status} for booking_id:#{booking.id}."
    end

    puts "#{DateTime.now.iso8601} Ending BookingAutoEndJob for #{booking.id}"
  end
end
