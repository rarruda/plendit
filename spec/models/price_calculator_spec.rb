require 'rails_helper'

RSpec.describe PriceCalculator, type: :model do



  context 'when ad does not have insurance and has only day price' do
    let(:price_calculator) { FactoryGirl.build( :price_calculator,
        ad: FactoryGirl.build( :ad_bap,
          user: FactoryGirl.build(:user),
          price_rules: [ FactoryGirl.build(:price_rule, unit: 'day', effective_from_unit: 1, amount: 100_00 ) ]
        )
      )
    }

    it "should calculate price of 1 hour" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 1

      expect(price_calculator.platform_fee).to   eq (10_00)
      expect(price_calculator.insurance_fee).to  eq ( 0_00)
      expect(price_calculator.payout_amount).to  eq (90_00)
    end

    it "should calculate price of 2 hours" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 2

      expect(price_calculator.platform_fee).to   eq (10_00)
      expect(price_calculator.insurance_fee).to  eq ( 0_00)
      expect(price_calculator.payout_amount).to  eq (90_00)
    end

    it "should calculate price of 1 day" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 1

      expect(price_calculator.platform_fee).to   eq (10_00)
      expect(price_calculator.insurance_fee).to  eq ( 0_00)
      expect(price_calculator.payout_amount).to  eq (90_00)
    end

    it "should calculate price of 2 days" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 2

      expect(price_calculator.platform_fee).to   eq ( 20_00)
      expect(price_calculator.insurance_fee).to  eq (  0_00)
      expect(price_calculator.payout_amount).to  eq (180_00)
    end
  end

  context 'when bap ad does have insurance and has only day price' do
    let(:price_calculator) { FactoryGirl.build( :price_calculator,
        ad: FactoryGirl.build_stubbed( :ad_bap,
          insurance_required: true,
          user: FactoryGirl.build(:user),
          price_rules: [ FactoryGirl.build(:price_rule, unit: 'day', effective_from_unit: 1, amount: 100_00 ) ]
        )
      )
    }

    it "should calculate price of 1 day" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 1

      expect(price_calculator.platform_fee).to   eq (10_00)
      expect(price_calculator.insurance_fee).to  eq ( 8_00)
      expect(price_calculator.payout_amount).to  eq (82_00)
      expect(price_calculator.reservation_amount).to eq (0)
    end

    it "should calculate price of 2 days" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 2

      expect(price_calculator.platform_fee).to   eq ( 20_00)
      expect(price_calculator.insurance_fee).to  eq ( 16_00)
      expect(price_calculator.payout_amount).to  eq (164_00)
    end
  end

  context 'when bap ad does have insurance and has both hour and multiple day prices' do
    let(:price_calculator) { FactoryGirl.build( :price_calculator,
        ad: FactoryGirl.build_stubbed( :ad_bap,
          insurance_required: true,
          user: FactoryGirl.build(:user),
          price_rules: [
            FactoryGirl.build(:price_rule, unit: 'hour', effective_from_unit: 1, amount:  50_00 ),
            FactoryGirl.build(:price_rule, unit: 'hour', effective_from_unit: 4, amount:  30_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 1, amount: 200_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 3, amount: 180_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 7, amount: 120_00 ),
          ]
        )
      )
    }

    it "should calculate price of 1 hour" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 1

      expect(price_calculator.platform_fee).to   eq ( 5_00)
      expect(price_calculator.insurance_fee).to  eq ( 4_00)
      expect(price_calculator.payout_amount).to  eq (41_00)
    end

    it "should calculate price of 2 hours" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 2

      expect(price_calculator.platform_fee).to   eq (10_00)
      expect(price_calculator.insurance_fee).to  eq ( 8_00)
      expect(price_calculator.payout_amount).to  eq (82_00)
    end

    it "should calculate price of 3 hours (get price for 4 hours)" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 3

      expect(price_calculator.platform_fee).to   eq ( 15_00)
      expect(price_calculator.insurance_fee).to  eq ( 12_00)
      expect(price_calculator.payout_amount).to  eq (123_00)
    end

    it "should calculate price of 4 hours" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 4

      expect(price_calculator.platform_fee).to   eq ( 12_00)
      expect(price_calculator.insurance_fee).to  eq (  9_60)
      expect(price_calculator.payout_amount).to  eq ( 98_40)
    end

    it "should calculate price of 6 hours" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 6

      expect(price_calculator.platform_fee).to   eq ( 18_00)
      expect(price_calculator.insurance_fee).to  eq ( 14_40)
      expect(price_calculator.payout_amount).to  eq (147_60)
    end

    it "should calculate price of 8 hours (get day price)" do
      price_calculator.unit = 'hour'
      price_calculator.duration_in_unit = 8

      expect(price_calculator.platform_fee).to   eq ( 20_00)
      expect(price_calculator.insurance_fee).to  eq ( 16_00)
      expect(price_calculator.payout_amount).to  eq (164_00)
    end

    it "should calculate price of 1 day" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 1

      expect(price_calculator.platform_fee).to   eq ( 20_00)
      expect(price_calculator.insurance_fee).to  eq ( 16_00)
      expect(price_calculator.payout_amount).to  eq (164_00)
    end

    it "should calculate price of 3 days" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 3

      expect(price_calculator.platform_fee).to     eq ( 54_00)
      expect(price_calculator.insurance_fee).to    eq ( 43_20)
      expect(price_calculator.payout_amount).to    eq (442_80)
      #expect(price_calculator.price_from_rules).to eq (540_00)
    end

    it "should calculate price of 7 days" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 7

      expect(price_calculator.platform_fee).to   eq ( 84_00)
      expect(price_calculator.insurance_fee).to  eq ( 67_20)
      expect(price_calculator.payout_amount).to  eq (688_80)
    end

    it "should calculate price of 10 days" do
      price_calculator.unit = 'day'
      price_calculator.duration_in_unit = 10

      expect(price_calculator.platform_fee).to     eq ( 120_00)
      expect(price_calculator.insurance_fee).to    eq (  96_00)
      expect(price_calculator.payout_amount).to    eq ( 984_00)
      #expect(price_calculator.price_from_rules).to eq (1200_00)
    end
  end

  context 'when motor ad does have insurance and has both hour and multiple day prices' do
    let(:price_calculator) { FactoryGirl.build( :price_calculator,
        ad: FactoryGirl.build_stubbed( :ad_motor,
          insurance_required: true,
          user: FactoryGirl.build(:user),
          price_rules: [
            FactoryGirl.build(:price_rule, unit: 'hour', effective_from_unit: 1, amount:  200_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 1, amount: 1000_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 3, amount:  800_00 ),
            FactoryGirl.build(:price_rule, unit: 'day',  effective_from_unit: 7, amount:  700_00 ),
          ]
        )
      )
    }

    it "should calculate price of 15 minutes" do
      price_calculator.starts_at = DateTime.now
      price_calculator.ends_at   = 15.minutes.from_now

      expect(price_calculator.platform_fee).to     eq (  20_00)
      expect(price_calculator.insurance_fee).to    eq (  18_00)
      expect(price_calculator.payout_amount).to    eq ( 162_00)
      expect(price_calculator.price_from_rules).to eq ( 200_00)
      expect(price_calculator.reservation_amount).to eq (1000_00)
    end

    it "should calculate price of 4 hours" do
      price_calculator.starts_at = DateTime.now
      price_calculator.ends_at   = 4.hours.from_now

      expect(price_calculator.platform_fee).to     eq (  80_00)
      expect(price_calculator.insurance_fee).to    eq (  72_00)
      expect(price_calculator.payout_amount).to    eq ( 648_00)
      expect(price_calculator.price_from_rules).to eq ( 800_00)
      expect(price_calculator.reservation_amount).to eq (1000_00)
    end

    it "should calculate price of 1 day" do
      price_calculator.starts_at = DateTime.now
      price_calculator.ends_at   = 1.day.from_now

      expect(price_calculator.platform_fee).to     eq ( 100_00)
      expect(price_calculator.insurance_fee).to    eq (  90_00)
      expect(price_calculator.payout_amount).to    eq ( 810_00)
      expect(price_calculator.price_from_rules).to eq (1000_00)
      expect(price_calculator.reservation_amount).to eq (1000_00)
    end

    it "should calculate price of 1 week" do
      price_calculator.starts_at = DateTime.now
      price_calculator.ends_at   = 7.days.from_now

      expect(price_calculator.platform_fee).to     eq ( 490_00)
      expect(price_calculator.insurance_fee).to    eq ( 441_00)
      expect(price_calculator.payout_amount).to    eq (3969_00)
      expect(price_calculator.price_from_rules).to eq (4900_00)
      expect(price_calculator.reservation_amount).to eq (1000_00)
    end
  end

end
