require 'rails_helper'


RSpec.describe Ad, :type => :model do
  it_behaves_like "Searcheable"

  it "should work on a valid model" do
    ad = FactoryGirl.build_stubbed(:ad, user: FactoryGirl.build_stubbed(:user) )
    expect(ad).to be_valid
  end

  it "should work on a model for category motor with a valid registration number" do
    ad = FactoryGirl.build_stubbed(:ad_motor, user: FactoryGirl.build_stubbed(:user) )
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