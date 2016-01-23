require 'rails_helper'

#https://github.com/eliotsykes/rspec-rails-examples/blob/master/spec/models/subscription_spec.rb

RSpec.describe User, :type => :model do


  context "attributes" do
    it "has email" do
      expect(User.new(email: "x@y.z")).to have_attributes(email: "x@y.z")
    end

    it "has name" do
      expect(User.new(name: "Ola Normann")).to have_attributes(name: "Ola Normann")
    end

    it "has confirmation_token" do
      expect(User.new(confirmation_token: "what-a-token")).to have_attributes(confirmation_token: "what-a-token")
    end
  end


  # context "validation" do

  #   before do
  #     @user = User.new(confirmation_token: "token", email: "a@b.c")
  #   end

  #   it "requires unique email" do
  #     expect(@user).to validate_presence_of(:email)
  #   end
  # end

  # context 'when setting phone_number' do
  #   let(:user) { FactoryGirl.build :user }
  #   let(:mock_mangopay_service) { double(MangopayService) }
  #   let(:mock_sms_service) { double(SmsService) }

  #   before do
  #     allow(MangopayService).to receive(:new).with(user).and_return(mock_mangopay_service)
  #     allow(SmsService).to receive(:new).and_return(mock_sms_service)
  #   end

  #   it "will have a phone_verification confirmation_token" do
  #     expect(mock_mangopay_service).to receive(:provision_user)
  #     expect(mock_sms_service).to receive(:process)

  #     user.unconfirmed_phone_number = '99994444'
  #     user.save
  #     expect(user.phone_number_confirmation_token).to match(/\A[0-9]{6}\Z/)
  #   end
  # end

  context 'when confirming phone_number' do
  end


end