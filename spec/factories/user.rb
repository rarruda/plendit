require 'faker'

Faker::Config.locale = 'nb-NO'

FactoryGirl.define do
  factory :user do |f|
    f.first_name    { Faker::Name.first_name }
    f.last_name     { Faker::Name.last_name }
    f.name          { Faker::Name.name }
    #f.phone_number  { [4,9].sample.to_s + Faker::Base.numerify('#######') }
    f.email         { Faker::Internet.safe_email(f.first_name) }
    f.password      { Faker::Internet.password(10, 20) }
    f.status        { 1 }

    # now the same user, but with an identity: (google)
    factory :user_with_identity, class: 'User' do |f|
      ### https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#associations
      transient do
        identity_count 1
      end
      after(:build) do |user, identity|
        create_list(:identity, identity.identity_count, user: user)
      end
    end
  end
end