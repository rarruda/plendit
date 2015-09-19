FactoryGirl.define do
  factory :mangopay_webhook do
    event_type_mp "PAYIN_NORMAL_CREATED"
    resource_type "MyString"
    resource_vid "1309853"
    date_mp 1397037093
  end

end
