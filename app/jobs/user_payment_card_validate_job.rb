class UserPaymentCardValidateJob < ActiveJob::Base
  queue_as :high

  def perform( user_payment_card )
    puts "#{DateTime.now.iso8601} Starting UserPaymentCardValidateJob"

    user_payment_card.validate_on_mangopay

    puts "#{DateTime.now.iso8601} Ending UserPaymentCardValidateJob for #{user_payment_card.id}"
  end
end
