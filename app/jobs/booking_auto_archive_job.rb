class BookingAutoArchiveJob < ActiveJob::Base
  queue_as :low

  def perform booking
    booking.archive!
  end
end
