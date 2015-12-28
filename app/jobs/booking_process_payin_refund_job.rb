class BookingProcessPayinRefundJob < ActiveJob::Base
  queue_as :high

  def perform(booking)
    puts "#{DateTime.now.iso8601} Starting #{self.class.name} for booking_id:#{booking.id}"

    # Process all existing payin_refund financial_transactions in this booking
    # Important that this happens in the worker, as this can take some time...
    booking.financial_transactions.payin_refund.pending_or_processing.each do |ft|
      if ft.pending?
        ft.process!
      elsif ft.processing?
        # there is no refreshing for payin_refund... (at least for now)
        # ft.process_refresh!
      end
    end

    if booking.financial_transactions.payin_refund.pending_or_processing.any?
      # log that there are still pending financial transactions

      pending_or_processing = booking.financial_transactions.payin_refund.pending_or_processing.map(&:id).join(',')
      puts "Following financial_transactions_ids are still pending or processing: #{pending_or_processing}"
    end

    puts "#{DateTime.now.iso8601} Ending #{self.class.name} for booking_id:#{booking.id}"
  end
end