require 'rails_helper'

RSpec.describe Price, type: :model do

  it "contains two price_items from the factory" do
    price = FactoryGirl.create(:price)
    expect(price.price_items.count).to eq(2)
  end

  it "contains at least one price for effective for duration over 7 days" do
    price = FactoryGirl.create(:price_week)
    prices_over_a_week = price.price_items.where("effective_from_unit >= ?", 7)
    expect(prices_over_a_week.count).to be > 0
  end

end
