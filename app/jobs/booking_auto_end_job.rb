class BookingAutoEndJob < ActiveJob::Base
  queue_as :high

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoEndJob"

    booking.end!

    puts "#{DateTime.now.iso8601} Ending BookingAutoEndJob for #{booking.id}"
  end
end
