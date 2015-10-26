require 'rails_helper'

RSpec.describe PriceItem, type: :model do

  it "should work on a valid model" do
    price_item = FactoryGirl.build_stubbed(:price_item)
    expect(price_item).to be_valid
  end

  it "should not accept effective_from_unit gt 23 for hours" do
    price_item = FactoryGirl.build_stubbed(:price_item, unit: 'hour', effective_from_unit: 24)
    expect(price_item).not_to be_valid
  end

  it "should not accept very low day prices" do
    price_item = FactoryGirl.build_stubbed(:price_item, unit: 'day', amount: 1_00)
    expect(price_item).not_to be_valid
  end

  it "should not accept very high prices" do
    price_item = FactoryGirl.build_stubbed(:price_item, amount: 10_000_000_00)
    expect(price_item).not_to be_valid
  end

  it "should accept 25 NOK as minimum price" do
    price_item = FactoryGirl.build_stubbed(:price_item, amount: 25_00)
    expect(price_item).to be_valid
  end
end
