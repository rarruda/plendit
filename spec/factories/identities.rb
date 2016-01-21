FactoryGirl.define do
  factory :identity do
    provider   'google'
    uid        '104663468663931358817'
    image_url  'https://robohash.org/foo.png'
    created_at 2.days.ago
    updated_at 2.days.ago
    email      Faker::Internet.safe_email()
    name       Faker::Name.name
    first_name Faker::Name.first_name
    last_name  Faker::Name.last_name
  end
end