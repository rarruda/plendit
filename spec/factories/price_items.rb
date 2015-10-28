FactoryGirl.define do
  factory :price_item do
    price nil
    unit  'day'
    amount 100_00
    effective_from_unit 1

    factory :price_item_hour do
      unit 'hour'
      amount 50_00
    end
  end

end
