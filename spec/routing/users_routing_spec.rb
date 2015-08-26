require 'rails_helper'

RSpec.describe "routing to users", :type => :routing do
  context "Users control panel routes" do
    it "routes /user/:id to users#show for user_id" do
      expect(:get => "/user/321").to route_to(
        :controller => "users",
        :action => "show",
        :id => "321"
      )
    end

    it "routes /me to current users profile page" do
      expect(:get => "/me").to route_to(
        :controller => "users",
        :action => "index",
      )
    end

    it "routes /me/ads to ads#list" do
      expect(:get => "/me/ads").to route_to(
        :controller => "ads",
        :action => "list",
      )
    end

    it "routes /me/edit to users#edit" do
      expect(:get => "/me/edit").to route_to(
        :controller => "users",
        :action => "edit",
      )
    end
  end

  context "Ads routes" do
    it "routes /ads/123 to ads#show with :id 123" do
      expect(:get => "/ads/123").to route_to(
        :controller => "ads",
        :action => "show",
        :id => "123"
      )
    end
  end

  context "Core routes for the site to work" do
    it "routes /search to ads#search" do
      expect(:get => "/search").to route_to(
        :controller => "ads",
        :action => "search"
      )
    end
    it "routes /new to ads#new" do
      expect(:get => "/new").to route_to(
        :controller => "ads",
        :action => "new"
      )
    end
  end

  # it "does not expose a list of profiles" do
  #   expect(:get => "/me").not_to be_routable
  # end
end