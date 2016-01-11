class BookingAutoAdjustStatusJob < ActiveJob::Base
  queue_as :low

  def perform
    puts "#{DateTime.now.iso8601} Starting BookingAutoAdjustStatusJob"

    # probably should be implemented with guards in the AASM
    # and select with may_perform_action

    puts "#{DateTime.now.iso8601} - created, for longer then 2 days need to be aborted. (unprocessed preauth)"
    # find all confirmed, with created_at < 7.days.ago
    # and abort! them
    Booking.created.where('created_at < ?', 2.days.ago ).map(&:payment_preauthorization_fail!)


    puts "#{DateTime.now.iso8601} - payment_preauthorized, for longer then 7 days need to be aborted. (unanswered booking requests)"
    # find all confirmed, with created_at < 7.days.ago
    # and abort! them
    Booking.payment_preauthorized.where('created_at < ?', 7.days.ago ).map(&:abort!)


    #puts "#{DateTime.now.iso8601} - confirmed, for longer then 1 days need to be SOMETHING!!. (payment not processed?)"
    # find all confirmed, with created_at < 1.day.ago
    # and Schedule job to run?(BookingProcessPayin) or abort! (cancel?) them
    #Booking.confirmed.where('created_at < ?', 1.days.ago ).map(&:abort!)


    # If not confirmed before starts_at + 24h, or has already passed ends_at, then abort!
    puts "#{DateTime.now.iso8601} - abort payment_preauthorized, which should have been confirmed by now"
    # find all payment_preauthorized, with starts_at < 1.day.ago or ends_at < DateTime.now
    # and abort! them
    Booking.payment_preauthorized.where('starts_at < ? OR ends_at < ? )', 1.days.ago, DateTime.now ).map(&:abort!)


    puts "#{DateTime.now.iso8601} - bumping payment_confirmed, which should have been started already"
    # find all payment_confirmed with starts_at < DateTime.now
    # and start! them
    Booking.payment_confirmed.where('starts_at < ?', DateTime.now ).map(&:start!)


    puts "#{DateTime.now.iso8601} - bumping started, which should have been in_progress already"
    # find all started with starts_at < 1.day.ago
    # and set_in_progress! them
    Booking.started.where('starts_at < ?', 1.day.ago ).map(&:set_in_progress!)


    puts "#{DateTime.now.iso8601} - bumping in_progress, which should have been ended already"
    # find all in_progress with ends_at > DateTime.now
    # and end! them
    # NOTE: this is just a faster version of Booking.active.select(&:should_be_in_progress?)
    Booking.in_progress.where('ends_at < ?', DateTime.now ).map(&:end!)


    puts "#{DateTime.now.iso8601} - bumping ended, which should have been archived already"
    # find all ended with ends_at > 7.days
    # and archive! them
    Booking.ended.where('ends_at > ?', 7.days.ago ).map(&:archive!)


    puts "#{DateTime.now.iso8601} Ending BookingAutoAdjustStatusJob"
  end
end
