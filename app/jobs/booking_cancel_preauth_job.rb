class BookingCancelPreauthJob < ActiveJob::Base
  queue_as :high

  def perform(booking)
    booking.cancel_all_financial_transaction_preauth!
  end
end
