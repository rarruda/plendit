require 'rails_helper'

RSpec.describe Price, type: :model do

  it "contains one price_items from the factory" do
    price = FactoryGirl.create(:price)
    expect(price.price_items.count).to eq(1)
  end

  it "contains at least one price for effective for duration over 7 days" do
    price = FactoryGirl.create(:price_week)
    prices_over_a_week = price.price_items.where("effective_from_unit >= ?", 7)
    expect(prices_over_a_week.count).to be > 0
  end

  it "does not allow adding an extra price which aggregated is lower then a previous unit price" do
    price = FactoryGirl.create(:price)
    price.price_items.build(unit: 'day', amount: 25_00, effective_from_unit: 2 )
    expect( price ).not_to be_valid
  end
end
