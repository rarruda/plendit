#require 'faker'
#Faker::Config.locale = 'nb-NO'

Geocoder.configure(:lookup => :test) if Rails.env == 'test'

Geocoder::Lookup::Test.add_stub(
  "Bentsebrugata 23B, 0469, Oslo", [
    {
      'latitude'     => 59.9382258,
      'longitude'    => 10.7611172,
      'address'      => 'Bentsebrugata 23B, 0469 Oslo, Norway',
      'city'         => 'Oslo',
      'state'        => 'Oslo',
      'postal_code'  => '0469',
      'country'      => 'Norway',
      'country_code' => 'NO'
    }
  ]
)

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
