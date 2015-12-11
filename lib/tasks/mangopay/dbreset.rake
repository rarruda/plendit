namespace :mangopay do
  desc 'Reset database of all mangopay related entities.'
  task dbreset: :environment do
    if Rails.env.production?
      puts "You cannot run this rake task in production."
      exit 1
    end

    unless ARGV.include? '--iknowwhatiamdoing'
      puts "If you know what you are doing, run:"
      puts
      puts "  bundle exec rake mangopay:dbreset -- --iknowwhatiamdoing"
      puts
      puts "It will then flush the database of all mangopay related information, and a lot more."
      puts "This is a very destructive action, so use it with care."
      puts
    else
      puts "Destroying all Bookings and UserPaymentAccounts"
      [ Booking, UserPaymentAccount ].each{ |klass| klass.destroy_all }
      # delete_all will delete all cards w/o invalidating cards with mangopay (via callback).
      #UserPaymentCard.delete_all
      # destroy_all will invalidate all cards with mangopay via a callback before deleting
      #UserPaymentCard.destroy_all
      #User.all.where( personhood: nil).each{ |u| u.update_columns( personhood: 'natural' ) }

      User.all.select(&:mangopay_provisioned?).each do |user,i|
        puts "#{i}/#{user.id} - #{user.email}"
        user.update_columns(
          payin_wallet_vid:     nil,
          payout_wallet_vid:    nil,
          payment_provider_vid: nil
        )
      end
    end
  end
end