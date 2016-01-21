FactoryGirl.define do
  factory :booking do
    ad_item { FactoryGirl.build(:ad_item) }
  end
end