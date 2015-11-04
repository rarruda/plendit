FactoryGirl.define do
  factory :user do
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    name          { Faker::Name.name }
    #phone_number  { [4,9].sample.to_s + Faker::Base.numerify('#######') }
    email         { Faker::Internet.safe_email( first_name ) }
    #personhood    { User.personhoods[:natural] }
    status        { 1 }

    after(:build) { |u| u.password = Faker::Internet.password(10, 20) }
  end

  factory :user_complete, class: User do
    id          { '100' }
    first_name  { 'Ola' }
    last_name   { 'Normann' }
    email       { 'ola.nordmann@norge.no' }
    personhood  { User.personhoods[:natural] }
    birthday    { '2001-01-20' }
    status      { 1 }
    nationality { 'NO' }
    country_of_residence { 'NO' }
    after(:build) { |u| u.password = Faker::Internet.password(10, 20) }

    trait :has_payment_provider_vid do
        payment_provider_vid { '8795157x' }
    end
    trait :has_wallets_vid do
        payin_wallet_vid  { '8795158x' }
        payout_wallet_vid { '8872555x' }
    end

    factory :user_provisioned do
        has_payment_provider_vid
        has_wallets_vid
    end
    factory :user_part_provisioned do
        has_payment_provider_vid
    end
  end
end