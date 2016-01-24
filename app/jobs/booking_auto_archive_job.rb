class BookingAutoArchiveJob < ActiveJob::Base
  queue_as :low

  def perform booking
    puts "#{DateTime.now.iso8601} Starting BookingAutoArchiveJob for #{booking.id}"

    if booking.ended?
      booking.archive!
      puts "booking_id:#{booking.id} has now status: #{booking.status}"
    elsif [:admin_paused].include? booking.status
      puts "Refused to do anything for status admin_paused. current status: #{booking.status} for booking_id:#{booking.id}."
    else
      puts "ERROR: can not archive a booking, as it is not ended. current status: #{booking.status} for booking_id:#{booking.id}."
    end

    puts "#{DateTime.now.iso8601} Ending BookingAutoArchiveJob for #{booking.id}"
  end
end
