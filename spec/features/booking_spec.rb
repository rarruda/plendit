require 'rails_helper'


RSpec.describe Booking, type: :model do
  #describe 'Making a booking and paying for it' do


  context 'simple booking' do
    let(:ad) { FactoryGirl.build_stubbed(:ad_bap,
        user: FactoryGirl.build_stubbed(:user_a),
        payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day',  payin_amount: 100_00) ],
      )
    }
    let(:booking) { FactoryGirl.build_stubbed(:booking,
        # from_user: FactoryGirl.build_stubbed(:user_b,
        #   # user_payment_cards: [FactoryGirl.build_stubbed(:user_payment_card)],
        #   verification_level: 'internally_verified',
        #   birthday: 20.years.ago,
        # ) do |u|
        #   u.user_payment_cards << FactoryGirl.build_stubbed(:user_payment_card)
        # end,
        ad_item:   ad.ad_items.first,
        ad:        ad,
        starts_at: 1.day.from_now,
        ends_at:   3.days.from_now,
        status:    'payment_confirmed',
      )
      # after(:build) { |u| u.password = Faker::Internet.password(10, 20) }
    }

    # creating a valid booking requires a LOT of things being valid...
    # it "should be a valid booking" do
    #   #booking.starts_at = DateTime.now
    #   expect(booking).to be_valid
    # end

    it "should be started if starts_at has passed" do
      booking.status    = 'payment_confirmed'
      booking.starts_at = 2.days.ago
      booking.ends_at   = 1.day.from_now

      expect(booking.should_be_started?).to     be true
      expect(booking.should_be_in_progress?).to be false
      expect(booking.should_be_ended?).to       be false
      expect(booking.should_be_archived?).to    be false
    end

    it "should be in_progress if starts_at+24t has passed" do
      booking.status    = 'started'
      booking.starts_at = 2.days.ago
      booking.ends_at   = 2.day.from_now

      expect(booking.should_be_started?).to     be false
      expect(booking.should_be_in_progress?).to be true
      expect(booking.should_be_ended?).to       be false
      expect(booking.should_be_archived?).to    be false
    end

    it "should be ended if ends_at has passed" do
      booking.status    = 'in_progress'
      booking.starts_at = 3.days.ago
      booking.ends_at   = 1.day.ago

      expect(booking.should_be_started?).to     be false
      expect(booking.should_be_in_progress?).to be false
      expect(booking.should_be_ended?).to       be true
      expect(booking.should_be_archived?).to    be false
    end

    it "should be archived if ends_at+7.days has passed" do
      booking.status    = 'ended'
      booking.starts_at = 10.days.ago
      booking.ends_at   = 1.week.ago - 1.second

      expect(booking.should_be_started?).to     be false
      expect(booking.should_be_in_progress?).to be false
      expect(booking.should_be_ended?).to       be false
      expect(booking.should_be_archived?).to    be true
    end

    it "should have in_progress_at correctly for booking starting at the same day, single day booking" do
      booking.status    = 'payment_confirmed'
      booking.starts_at = DateTime.now
      booking.ends_at   = DateTime.now.end_of_day

      expect(booking.in_progress_at).to     be_within(1.minutes).of ( booking.ends_at - 1.minute )
    end

    it "should have in_progress_at correctly for booking starting at the same day, multiple day booking" do
      booking.status    = 'payment_confirmed'
      booking.starts_at = DateTime.now
      booking.ends_at   = 2.days.from_now

      expect(booking.in_progress_at).to     be_within(1.minutes).of ( booking.starts_at + 1.day )
    end

    it "should have in_progress_at correctly for booking starting in the future" do
      booking.status    = 'payment_confirmed'
      booking.starts_at = 1.day.from_now
      booking.ends_at   = 2.days.from_now

      expect(booking.in_progress_at).to     be_within(1.minutes).of ( booking.starts_at + 1.day )
    end

    it "should have archives_at correctly" do
      expect(booking.archives_at).to     be_within(1.minutes).of ( booking.ends_at + 1.week )
    end

  end

end