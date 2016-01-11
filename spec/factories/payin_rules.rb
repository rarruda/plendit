FactoryGirl.define do
  factory :payin_rule do
    unit  'day'
    payin_amount 100_00
    effective_from 1

    factory :payin_rule_ad_hour do
      ad FactoryGirl.build(:ad_bap)
      unit 'hour'
      payin_amount 50_00
    end

    factory :payin_rule_ad do
      ad FactoryGirl.build(:ad_bap)
    end
  end

end
