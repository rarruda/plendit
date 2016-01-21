FactoryGirl.define do
  factory :ad_item do
    ad  { FactoryGirl.build(:ad_bap) }
  end
end