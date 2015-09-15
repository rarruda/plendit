#require 'faker'
#Faker::Config.locale = 'nb-NO'

FactoryGirl.define do
  factory :location do |f|
    f.address_line  { "Bentsebrugata 23B" }
    f.city          { "Oslo" }
    f.state         { "Oslo" }
    f.post_code     { "0469" }

    association :user, factory: :user, strategy: :build
  end
end


#u.locations.create!({
#  "address_line"=>"Grensen  5-7",
#  "city"=>"Oslo",
#  "state"=>"Oslo",
#  "post_code"=>"0159"
#})
#u.locations.create!({
#  "address_line"=>"Støperigata 1",
#  "city"=>"Oslo",
#  "state"=>"Oslo",
#  "post_code"=>"0250"
#})
