require 'rails_helper'

RSpec.describe PriceRule, type: :model do

  it "should work on a valid model" do
    price_rule = FactoryGirl.build_stubbed(:price_rule)
    expect(price_rule).to be_valid
  end

  it "should not accept effective_from_unit gt 23 for hours" do
    price_rule = FactoryGirl.build_stubbed(:price_rule, unit: 'hour', effective_from_unit: 25)
    expect(price_rule).not_to be_valid
  end

  it "should not accept very low day prices" do
    price_rule = FactoryGirl.build_stubbed(:price_rule, unit: 'day', amount: 1_00)
    expect(price_rule).not_to be_valid
  end

  it "should not accept very high prices" do
    price_rule = FactoryGirl.build_stubbed(:price_rule, amount: 10_000_000_00)
    expect(price_rule).not_to be_valid
  end

  it "should accept 25 NOK as minimum price" do
    price_rule = FactoryGirl.build_stubbed(:price_rule, amount: 25_00)
    expect(price_rule).to be_valid
  end
end
