FactoryGirl.define do
  factory :user do
    #public_name   { Faker::Name.first_name }
    first_name    { 'Ola' }
    last_name     { 'Nordmann' }
    name          { 'Ola Nordmann' }
    #phone_number  { [4,9].sample.to_s + Faker::Base.numerify('#######') }
    email         { 'ola.nordmann@example.com' }
    personhood    { User.personhoods[:natural] }
    status        { 1 }

    after(:build) { |u| u.password = Faker::Internet.password(10, 20) }
  end

  factory :user_a_complete, class: User do
    id          { '100' }
    public_name { 'Andrea' }
    first_name  { 'Andrea' }
    last_name   { 'Normann' }
    email       { 'andrea.normann@example.org' }
    phone_number  { [4,9].sample.to_s + "000" + Faker::Base.numerify('####') }
    personhood  { User.personhoods[:natural] }
    birthday    { '2001-01-20' }
    status      { 1 }
    nationality { 'NO' }
    country_of_residence { 'NO' }
    after(:build) { |u| u.password = Faker::Internet.password(10, 20) }

    trait :has_payment_provider_vid do
        payment_provider_vid { '8700107' }
    end
    trait :has_wallets_vid do
        payin_wallet_vid  { '8700108' }
        payout_wallet_vid { '8700109' }
    end

    factory :user_a, class: User do
        has_payment_provider_vid
        has_wallets_vid
    end
    factory :user_a_mangopay_provisioned_part do
        has_payment_provider_vid
    end
  end

  factory :user_b, class: User do
    id           { '100' }
    public_name  { 'Bjørn' }
    first_name   { 'Bjørn' }
    last_name    { 'Sand' }
    email        { 'bjoern.sand@example.net' }
    phone_number { [4,9].sample.to_s + "0000" + Faker::Base.numerify('###') }
    personhood   { User.personhoods[:natural] }
    birthday     { '2001-01-01' }
    status       { 1 }
    nationality  { 'NO' }
    country_of_residence { 'NO' }
    after(:build) { |u| u.password = Faker::Internet.password(10, 20) }

    payment_provider_vid { '8700227' }
    payin_wallet_vid     { '8700228' }
    payout_wallet_vid    { '8700229' }
  end
end