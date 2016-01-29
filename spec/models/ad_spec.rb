require 'rails_helper'


RSpec.describe Ad, :type => :model do

  let(:ad_bap_not_stubbed) {
    ad = FactoryGirl.build(:ad_bap,
      body: "foo bar 123",
      user: FactoryGirl.build(:user),
      ad_images: [ FactoryGirl.build(:ad_image) ],
      payin_rules: [ FactoryGirl.build(:payin_rule, ad: FactoryGirl.build_stubbed(:ad_bap)) ]
    )
  }

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

  it "should set state to edited if the payin_rules has changed" do
    # needs to be valid for the rest of the test to work:
    expect(ad_bap_not_stubbed).to be_valid

    # start in draft
    expect(ad_bap_not_stubbed.status).to eq('draft')
    ad_bap_not_stubbed.submit_for_review
    expect(ad_bap_not_stubbed.status).to eq('waiting_review')

    # change data in a nested model:
    ad_bap_not_stubbed.payin_rules.first.payin_amount=200_00

    # trigger state change:
    ad_bap_not_stubbed.save
    expect(ad_bap_not_stubbed.status).to eq('draft')

  end

end