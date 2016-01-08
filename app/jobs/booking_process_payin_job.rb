class BookingProcessPayinJob < ActiveJob::Base
  # BookingProcessFinancialTransactionPreauth
  queue_as :high

  def perform(booking)
    puts "#{DateTime.now.iso8601} Starting #{self.class.name} for booking_id:#{booking.id}"

    # Process all existing payin financial_transactions in this booking
    # Important that this happens in the worker, as this can take some time...
    booking.financial_transactions.payin.pending_or_processing.each do |ft|
      if ft.pending?
        ft.process!
      elsif ft.processing?
        ft.process_refresh!
      end
    end


    if booking.financial_transactions.payin.errored_or_unknown_state.any?
      # this will refund all exiting (with status finished), payins for this booking

      booking.cancel_all_financial_transactions_payin
      booking.payment_fail!
      puts "Booking changed status to: #{booking.status}"

    elsif booking.financial_transactions.payin.pending_or_processing.any?
      # log that there are still pending financial transactions

      pending_or_processing = booking.financial_transactions.payin.pending_or_processing.map(&:id).join(',')
      puts "Following financial_transactions_ids are still pending or processing: #{pending_or_processing}"
    elsif booking.confirmed?
      # no pending, errored or in unknown state payin financial_transactions for this booking.
      # so, set booking status to payment_preauthorized (given that it comes from the correct state.)

      booking.payment_confirm!
      puts "Booking changed status to: #{booking.status}"
    else
      puts "Nothing to do for this booking. current booking_status: #{booking.status}"
      puts "And that is ok!" if booking.payment_confirmed?
    end

    puts "#{DateTime.now.iso8601} Ending #{self.class.name} for booking_id:#{booking.id}"
  end
end