class BookingAutoSetInProgressJob < ActiveJob::Base
  queue_as :default

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoSetInProgressJob"

    booking.set_in_progress!

    puts "#{DateTime.now.iso8601} Ending BookingAutoSetInProgressJob for #{booking.id}"
  end
end
