require 'rails_helper'

RSpec.describe BookingCalculator, type: :model do

  context 'when we override the payin_rule from the ad' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_bap,
          user: FactoryGirl.build_stubbed(:user),
          payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day', payin_amount: 100_00 ) ]
        )
      )
    }
    let(:payin_rule) {
      {
        day:      FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day',  payin_amount: 200_00 ),
        day_four: FactoryGirl.build_stubbed(:payin_rule, effective_from: 4, unit: 'day',  payin_amount: 150_00 ),
        hour:     FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'hour', payin_amount:  50_00 ),
        hour_two: FactoryGirl.build_stubbed(:payin_rule, effective_from: 2, unit: 'hour', payin_amount:  40_00 ),
        no_payin: FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day',  payin_amount:    nil )
      }
    }

    it { expect(booking_calculator.platform_fee  payin_rule[:day]).to  eq ( 12_00) }
    it { expect(booking_calculator.insurance_fee payin_rule[:day]).to  eq ( 18_00) }
    it { expect(booking_calculator.payout_amount payin_rule[:day]).to  eq (170_00) }

    it { expect(booking_calculator.platform_fee  payin_rule[:day_four]).to  eq (  9_00) }
    it { expect(booking_calculator.insurance_fee payin_rule[:day_four]).to  eq ( 13_50) }
    it { expect(booking_calculator.payout_amount payin_rule[:day_four]).to  eq (127_50) }

    it { expect(booking_calculator.platform_fee  payin_rule[:hour]).to  eq (  3_00) }
    it { expect(booking_calculator.insurance_fee payin_rule[:hour]).to  eq (  4_50) }
    it { expect(booking_calculator.payout_amount payin_rule[:hour]).to  eq ( 42_50) }

    it { expect(booking_calculator.platform_fee  payin_rule[:hour_two]).to  eq (  2_40) }
    it { expect(booking_calculator.insurance_fee payin_rule[:hour_two]).to  eq (  3_60) }
    it { expect(booking_calculator.payout_amount payin_rule[:hour_two]).to  eq ( 34_00) }

    it { expect(booking_calculator.platform_fee  payin_rule[:no_payin]).to  eq (  0_00) }
    it { expect(booking_calculator.insurance_fee payin_rule[:no_payin]).to  eq (  0_00) }
    it { expect(booking_calculator.payout_amount payin_rule[:no_payin]).to  eq (  0_00) }

  end

  context 'when ad has rule coming as a float' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_motor,
          user: FactoryGirl.build(:user)
        )
      )
    }
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day',  payin_amount_in_h: 250.0 ) }

    it { expect(booking_calculator.platform_fee  payin_rule).to     eq (  15_00) }
    it { expect(booking_calculator.insurance_fee payin_rule).to     eq (  22_50) }
    it { expect(booking_calculator.payout_amount payin_rule).to     eq ( 212_50) }
    it { expect(booking_calculator.payin_amount  payin_rule).to     eq ( 250_00) }
    it { expect(booking_calculator.deposit_amount           ).to    eq (1000_00) }
  end

  context 'when we override the payin_rule from the ad' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_motor,
          user: FactoryGirl.build_stubbed(:user),
          payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day', payin_amount: 100_00 ) ]
        )
      )
    }
    let(:payin_rule) {
      {
        day:      FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'day',  payin_amount: 300_00 ),
        hour:     FactoryGirl.build_stubbed(:payin_rule, effective_from: 1, unit: 'hour', payin_amount:  70_00 )
      }
    }

    it { expect(booking_calculator.platform_fee  payin_rule[:day]).to  eq (  18_00) }
    it { expect(booking_calculator.insurance_fee payin_rule[:day]).to  eq (  27_00) }
    it { expect(booking_calculator.payout_amount payin_rule[:day]).to  eq ( 255_00) }
    it { expect(booking_calculator.deposit_amount                 ).to eq (1000_00) }

    it { expect(booking_calculator.platform_fee  payin_rule[:hour]).to  eq (  4_20) }
    it { expect(booking_calculator.insurance_fee payin_rule[:hour]).to  eq (  6_30) }
    it { expect(booking_calculator.payout_amount payin_rule[:hour]).to  eq ( 59_50) }
  end

  context 'when bap ad has only day price' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_bap,
          user: FactoryGirl.build_stubbed(:user),
          payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, unit: 'day', effective_from: 1, payin_amount: 100_00 ) ]
        )
      )
    }

    it "should calculate price of 1 day" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 1.day.from_now

      expect(booking_calculator.platform_fee).to   eq (   6_00)
      expect(booking_calculator.insurance_fee).to  eq (   9_00)
      expect(booking_calculator.payout_amount).to  eq (  85_00)
      expect(booking_calculator.deposit_amount).to eq ( 500_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq ( 600_00)
    end

    it "should calculate price of 2 days" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 2.days.from_now

      expect(booking_calculator.platform_fee).to   eq ( 12_00)
      expect(booking_calculator.insurance_fee).to  eq ( 18_00)
      expect(booking_calculator.payout_amount).to  eq (170_00)
      expect(booking_calculator.deposit_amount).to eq (500_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (700_00)
    end
  end

  context 'when bap ad has both hour and multiple day prices' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_bap,
          user: FactoryGirl.build_stubbed(:user),
          payin_rules: [
            FactoryGirl.build(:payin_rule, unit: 'hour', effective_from: 1, payin_amount:  50_00 ),
            FactoryGirl.build(:payin_rule, unit: 'hour', effective_from: 4, payin_amount:  30_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 1, payin_amount: 200_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 3, payin_amount: 180_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 7, payin_amount: 120_00 ),
          ]
        )
      )
    }

    it "should calculate price of 1 hour" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 1.hour.from_now

      expect(booking_calculator.platform_fee).to   eq (  3_00)
      expect(booking_calculator.insurance_fee).to  eq (  4_50)
      expect(booking_calculator.payout_amount).to  eq ( 42_50)
      expect(booking_calculator.deposit_amount).to eq (500_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (550_00)
    end

    it "should calculate price of 2 hours" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 2.hours.from_now

      expect(booking_calculator.platform_fee).to   eq ( 6_00)
      expect(booking_calculator.insurance_fee).to  eq ( 9_00)
      expect(booking_calculator.payout_amount).to  eq (85_00)
    end

    it "should calculate price of 3 hours" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 3.hours.from_now

      expect(booking_calculator.platform_fee).to   eq (  9_00)
      expect(booking_calculator.insurance_fee).to  eq ( 13_50)
      expect(booking_calculator.payout_amount).to  eq (127_50)
    end

    it "should calculate price of 4 hours" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 4.hours.from_now

      expect(booking_calculator.platform_fee).to   eq (  7_20)
      expect(booking_calculator.insurance_fee).to  eq ( 10_80)
      expect(booking_calculator.payout_amount).to  eq (102_00)
    end

    it "should calculate price of 6 hours" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 6.hours.from_now

      expect(booking_calculator.platform_fee).to   eq ( 10_80)
      expect(booking_calculator.insurance_fee).to  eq ( 16_20)
      expect(booking_calculator.payout_amount).to  eq (153_00)
    end

    it "should calculate price of 8 hours (get day price)" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 8.hours.from_now

      expect(booking_calculator.platform_fee).to   eq ( 12_00)
      expect(booking_calculator.insurance_fee).to  eq ( 18_00)
      expect(booking_calculator.payout_amount).to  eq (170_00)
    end

    it "should calculate price of 1 day" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 1.day.from_now

      expect(booking_calculator.platform_fee).to   eq ( 12_00)
      expect(booking_calculator.insurance_fee).to  eq ( 18_00)
      expect(booking_calculator.payout_amount).to  eq (170_00)
      expect(booking_calculator.deposit_amount).to eq (500_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (700_00)
    end

    it "should calculate price of 3 days" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 3.days.from_now

      expect(booking_calculator.platform_fee).to     eq ( 32_40)
      expect(booking_calculator.insurance_fee).to    eq ( 48_60)
      expect(booking_calculator.payout_amount).to    eq (459_00)
      #expect(booking_calculator.payin_amount_from_rules).to eq (540_00)
    end

    it "should calculate price of 7 days" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 7.days.from_now

      expect(booking_calculator.platform_fee).to   eq ( 50_40)
      expect(booking_calculator.insurance_fee).to  eq ( 75_60)
      expect(booking_calculator.payout_amount).to  eq (714_00)
    end

    it "should calculate price of 10 days" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 10.days.from_now

      expect(booking_calculator.platform_fee).to     eq (  72_00)
      expect(booking_calculator.insurance_fee).to    eq ( 108_00)
      expect(booking_calculator.payout_amount).to    eq (1020_00)
      expect(booking_calculator.payin_amount).to     eq (1200_00)
      expect(booking_calculator.deposit_amount).to   eq ( 500_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (1700_00)

    end
  end

  context 'when motor ad has both hour and multiple day prices' do
    let(:booking_calculator) { FactoryGirl.build( :booking_calculator,
        ad: FactoryGirl.build_stubbed( :ad_motor,
          user: FactoryGirl.build(:user),
          payin_rules: [
            FactoryGirl.build(:payin_rule, unit: 'hour', effective_from: 1, payin_amount:  200_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 1, payin_amount: 1000_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 3, payin_amount:  800_00 ),
            FactoryGirl.build(:payin_rule, unit: 'day',  effective_from: 7, payin_amount:  700_00 ),
          ]
        )
      )
    }

    it "should calculate price of 15 minutes" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 15.minutes.from_now

      expect(booking_calculator.platform_fee).to     eq (  12_00)
      expect(booking_calculator.insurance_fee).to    eq (  18_00)
      expect(booking_calculator.payout_amount).to    eq ( 170_00)
      expect(booking_calculator.payin_amount).to     eq ( 200_00)
      expect(booking_calculator.deposit_amount).to   eq (1000_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (1200_00)
    end

    it "should calculate price of 4 hours" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 4.hours.from_now

      expect(booking_calculator.platform_fee).to     eq (  48_00)
      expect(booking_calculator.insurance_fee).to    eq (  72_00)
      expect(booking_calculator.payout_amount).to    eq ( 680_00)
      expect(booking_calculator.payin_amount).to     eq ( 800_00)
      expect(booking_calculator.deposit_amount).to   eq (1000_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (1800_00)
    end

    it "should calculate price of 1 day" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 1.day.from_now

      expect(booking_calculator.platform_fee).to     eq (  60_00)
      expect(booking_calculator.insurance_fee).to    eq (  90_00)
      expect(booking_calculator.payout_amount).to    eq ( 850_00)
      expect(booking_calculator.payin_amount).to     eq (1000_00)
      expect(booking_calculator.deposit_amount).to   eq (1000_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (2000_00)
    end

    it "should calculate price of 1 week" do
      booking_calculator.starts_at = DateTime.now
      booking_calculator.ends_at   = 7.days.from_now

      expect(booking_calculator.platform_fee).to     eq ( 294_00)
      expect(booking_calculator.insurance_fee).to    eq ( 441_00)
      expect(booking_calculator.payout_amount).to    eq (4165_00)
      expect(booking_calculator.payin_amount).to     eq (4900_00)
      expect(booking_calculator.deposit_amount).to   eq (1000_00)
      expect(booking_calculator.payin_with_deposit_amount).to eq (5900_00)
    end
  end

end
