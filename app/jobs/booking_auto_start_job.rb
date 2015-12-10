class BookingAutoStartJob < ActiveJob::Base
  queue_as :default

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoStartJob"

    booking.start!

    puts "#{DateTime.now.iso8601} Ending BookingAutoStartJob for #{booking.id}"
  end
end
