require 'rails_helper'


RSpec.describe Booking, type: :model do
  #describe 'Making a booking and paying for it' do


  context 'simple booking' do
    let(:ad) { FactoryGirl.build_stubbed(:ad_bap,
        user: FactoryGirl.build(:user_a),
        payin_rules: [ FactoryGirl.build(:payin_rule, effective_from: 1, unit: 'day',  payin_amount: 100_00) ],
      )
    }
    let(:ad_motor) { FactoryGirl.build(:ad_motor,
        ad_items:    [ FactoryGirl.build(:ad_item) ],
        user:        FactoryGirl.build(:user_a),
        payin_rules: [ FactoryGirl.build(:payin_rule, effective_from: 1, unit: 'day',  payin_amount: 100_00) ],
      )
    }
    let(:from_user) { FactoryGirl.build_stubbed(:user_b,
        # user_payment_cards: [FactoryGirl.build_stubbed(:user_payment_card)],
        verification_level: 'internally_verified',
        birthday: 20.years.ago,
      ) # do |u|
      #   u.user_payment_cards << FactoryGirl.build_stubbed(:user_payment_card)
      # end
    }
    let(:booking) { FactoryGirl.build_stubbed(:booking,
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
      booking.starts_at = 2.days.ago.beginning_of_day
      booking.ends_at   = 1.day.from_now.end_of_day

      expect(booking.should_be_started?).to     be true
      expect(booking.should_be_in_progress?).to be false
      expect(booking.should_be_ended?).to       be false
      expect(booking.should_be_archived?).to    be false
    end

    it "should be in_progress if starts_at+24t has passed" do
      booking.status    = 'started'
      booking.starts_at = 2.days.ago.beginning_of_day
      booking.ends_at   = 2.day.from_now.end_of_day

      expect(booking.should_be_started?).to     be false
      expect(booking.should_be_in_progress?).to be true
      expect(booking.should_be_ended?).to       be false
      expect(booking.should_be_archived?).to    be false
    end

    it "should be ended if ends_at has passed" do
      booking.status    = 'in_progress'
      booking.starts_at = 3.days.ago.beginning_of_day
      booking.ends_at   = 1.day.ago.end_of_day

      expect(booking.should_be_started?).to     be false
      expect(booking.should_be_in_progress?).to be false
      expect(booking.should_be_ended?).to       be true
      expect(booking.should_be_archived?).to    be false
    end

    it "should be archived if ends_at+7.days has passed" do
      booking.status    = 'ended'
      booking.starts_at = 10.days.ago.beginning_of_day
      booking.ends_at   = 8.days.ago.end_of_day - 1.second

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
      booking.ends_at   = 2.days.from_now.end_of_day

      expect(booking.in_progress_at).to     be_within(1.minutes).of ( booking.starts_at + 1.day )
    end

    it "should have in_progress_at correctly for booking starting in the future" do
      booking.status    = 'payment_confirmed'
      booking.starts_at = 1.day.from_now.beginning_of_day
      booking.ends_at   = 2.days.from_now.end_of_day

      expect(booking.in_progress_at).to     be_within(1.minutes).of ( booking.starts_at + 1.day )
    end

    it "should have archives_at correctly" do
      expect(booking.archives_at).to     be_within(1.minutes).of ( booking.ends_at + 1.week )
    end

    it "should not allow renter to may_set_deposit_offer_amount? when payment_confirmed" do
      booking = FactoryGirl.build_stubbed(:booking,
        #ad_item:   ad.ad_items.first,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 1.day.from_now,
        ends_at:   3.days.from_now.end_of_day,
        status:    'payment_confirmed',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be false
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end

    it "should allow renter to may_set_deposit_offer_amount? when started" do
      booking = FactoryGirl.build_stubbed(:booking,
        #ad_item:   ad_motor.ad_items.first,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 1.day.from_now.beginning_of_day,
        ends_at:   3.days.from_now.end_of_day,
        status:    'started',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be true
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end

    it "should allow renter to may_set_deposit_offer_amount? when in_progress" do
      booking = FactoryGirl.build_stubbed(:booking,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 1.day.ago.beginning_of_day,
        ends_at:   3.days.from_now.end_of_day,
        status:    'in_progress',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be true
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end

    it "should not allow renter to may_set_deposit_offer_amount? when ended" do
      booking = FactoryGirl.build_stubbed(:booking,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 3.days.ago.beginning_of_day,
        ends_at:   1.day.ago.end_of_day,
        status:    'ended',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be false
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end



    it "should not allow renter to may_set_deposit_offer_amount? when archived" do
      booking = FactoryGirl.build_stubbed(:booking,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 9.days.ago.beginning_of_day,
        ends_at:   8.days.ago.end_of_day,
        status:    'archived',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be false
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end

    it "should not allow owner to may_set_deposit_offer_amount?" do
      booking = FactoryGirl.build_stubbed(:booking,
        ad:        ad_motor,
        from_user: from_user,
        starts_at: 1.day.from_now.beginning_of_day,
        ends_at:   3.days.from_now.end_of_day,
        status:    'payment_confirmed',
      )

      expect(booking.may_set_deposit_offer_amount? booking.from_user).to be false
      expect(booking.may_set_deposit_offer_amount? booking.user).to      be false
    end

  end

end