require "rails_helper"

RSpec.describe UserPaymentCardsController, type: :routing do
  describe "routing" do

    xit "routes to #index" do
      expect(:get => "/user_payment_cards").to route_to("user_payment_cards#index")
    end

    xit "routes to #new" do
      expect(:get => "/user_payment_cards/new").to route_to("user_payment_cards#new")
    end


    xit "routes to #create" do
      expect(:post => "/user_payment_cards").to route_to("user_payment_cards#create")
    end

    xit "routes to #update via PUT" do
      expect(:put => "/user_payment_cards/1").to route_to("user_payment_cards#update", :id => "1")
    end

    xit "routes to #update via PATCH" do
      expect(:patch => "/user_payment_cards/1").to route_to("user_payment_cards#update", :id => "1")
    end

    xit "routes to #destroy" do
      expect(:delete => "/user_payment_cards/1").to route_to("user_payment_cards#destroy", :id => "1")
    end

  end
end
