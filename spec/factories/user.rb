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


    # now the same user, but with an identity: (google)
    #factory :user_with_identity, class: 'User' do
    #  ### https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#associations
    #  transient do
    #    identity_count 1
    #  end
    #  after(:build) do |user, identity|
    #    create_list(:identity, identity.identity_count, user: user)
    #  end
    #end
  end
end