FactoryGirl.define do
  factory :price_rule do
    ad nil
    unit  'day'
    amount 100_00
    effective_from_unit 1

    factory :price_rule_hour do
      unit 'hour'
      amount 50_00
    end
  end

end
