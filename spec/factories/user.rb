require 'faker'

Faker::Config.locale = 'nb-NO'

FactoryGirl.define do
  factory :user do |f|
    f.first_name    { Faker::Name.first_name }
    f.last_name     { Faker::Name.last_name }
    f.name          { Faker::Name.name }
    f.phone_number  { [4,9].sample.to_s + Faker::Base.numerify('#######') }
    f.email         { Faker::Internet.safe_email(f.first_name) }
    f.password      { Faker::Internet.password(10, 20) }
    f.status        { 2 }
  end
end