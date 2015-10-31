require 'rails_helper'

RSpec.describe PayinRule, type: :model do

  it "should work on a valid model" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule)
    expect(payin_rule).to be_valid
  end

  it "should not accept effective_from_unit gt 23 for hours" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule, unit: 'hour', effective_from: 25)
    expect(payin_rule).not_to be_valid
  end

  it "should not accept very low day prices" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule, unit: 'day', payin_amount: 1_00)
    expect(payin_rule).not_to be_valid
  end

  it "should not accept very high prices" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule, payin_amount: 10_000_000_00)
    expect(payin_rule).not_to be_valid
  end

  it "should accept 25 NOK as minimum price" do
    payin_rule = FactoryGirl.build_stubbed(:payin_rule, payin_amount: 25_00)
    expect(payin_rule).to be_valid
  end

  context "when payin_rule has a simple day price rule" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule, unit: 'day', payin_amount: 200_00,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }
    let(:duration) { 4.days.to_i }

    it "should generate correctly prices for one unit" do
      expect(payin_rule.payin_amount_for_duration).to  eq(200_00)
    end

    it "should generate correctly prices for multiple units" do
      expect(payin_rule.payin_amount_for_duration  duration).to eq(800_00)
    end
  end

  context "when payin_rule has a simple hour price rule" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule_hour, unit: 'hour', payin_amount: 100_00,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }
    let(:duration) { 4.hours.to_i }

    it { expect(payin_rule.payin_amount_for_duration).to  eq(100_00) }
    it { expect(payin_rule.payin_amount_for_duration duration).to eq(400_00) }
  end


  context "when payin_rule payin_amount comes as a float" do
    let(:payin_rule) { FactoryGirl.build_stubbed(:payin_rule_hour, unit: 'hour', payin_amount_in_h: 250.0,
        ad: FactoryGirl.build_stubbed(:ad_motor) )
      }

    it { expect(payin_rule.payin_amount).to      eq ( 250_00) }
    it { expect(payin_rule.payin_amount_in_h).to eq ( 250.00) }
  end
end
