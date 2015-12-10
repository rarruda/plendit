class BookingAutoArchiveJob < ActiveJob::Base
  queue_as :low

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoArchiveJob"

    booking.archive!

    puts "#{DateTime.now.iso8601} Ending BookingAutoArchiveJob for #{booking.id}"
  end
end
