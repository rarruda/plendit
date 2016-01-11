require 'rails_helper'


RSpec.describe Ad, :type => :model do
  it_behaves_like "Searcheable"

  it "should work on a valid model" do
    ad = FactoryGirl.build_stubbed(:ad_bap,
      body: "foo bar 123",
      user: FactoryGirl.build_stubbed(:user),
      ad_images: [ FactoryGirl.build_stubbed(:ad_image) ],
      payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, ad: FactoryGirl.build_stubbed(:ad_bap)) ]
    )
    expect(ad).to be_valid
  end

  it "should work on a model for category motor with a valid registration number" do
    ad = FactoryGirl.build_stubbed(:ad_motor,
      body: "foo bar 123",
      user: FactoryGirl.build_stubbed(:user),
      ad_images: [ FactoryGirl.build_stubbed(:ad_image) ],
      payin_rules: [ FactoryGirl.build_stubbed(:payin_rule, ad: FactoryGirl.build_stubbed(:ad_motor) )  ]
    )
    expect(ad).to be_valid
  end

  it "should fail on a model for category motor without registration number" do
    ad = FactoryGirl.build_stubbed(:ad_motor, user: FactoryGirl.build_stubbed(:user),
      registration_number: nil
    )
    expect(ad).not_to be_valid
  end

  it "should fail on a model for category motor with an invalid registration number" do
    ad = FactoryGirl.build_stubbed(:ad_motor, user: FactoryGirl.build_stubbed(:user),
      registration_number: 'FOOBAR123X'
    )
    expect(ad).not_to be_valid
  end
end