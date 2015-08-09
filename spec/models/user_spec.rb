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



end