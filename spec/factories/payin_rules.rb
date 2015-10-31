FactoryGirl.define do
  factory :payin_rule do
    ad nil
    unit  'day'
    payin_amount 100_00
    effective_from 1

    factory :payin_rule_hour do
      unit 'hour'
      payin_amount 50_00
    end
  end

end
