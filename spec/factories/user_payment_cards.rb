FactoryGirl.define do
  factory :user_payment_card do
    guid          "0b0180bb-aae3-4a2a-bc06-2101e26e71d6"
    #user_id       100
    card_vid      "9077893"
    card_type     "CB_VISA_MASTERCARD"
    card_provider "VISA"
    currency      "NOK"
    country       "RUS"
    active        true
    favorite      false
    validity        'card_valid'
    number_alias    "497010XXXXXX0154"
    expiration_date "0219"
  end

end
