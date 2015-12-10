class BookingAutoSetInProgressJob < ActiveJob::Base
  queue_as :high

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoSetInProgressJob"

    booking.set_in_progress!

    puts "#{DateTime.now.iso8601} Ending BookingAutoSetInProgressJob for #{booking.id}"
  end
end
