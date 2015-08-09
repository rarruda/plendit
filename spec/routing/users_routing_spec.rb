require 'rails_helper'

RSpec.describe "routing to users", :type => :routing do
  it "routes /users/:id to users#show for user_id" do
    expect(:get => "/users/1").to route_to(
      :controller => "users",
      :action => "show",
      :id => "1"
    )
  end

  it "routes to current users profile page" do
    expect(:get => "/users").to route_to(
      :controller => "users",
      :action => "index",
    )
  end
  # it "does not expose a list of profiles" do
  #   expect(:get => "/users").not_to be_routable
  # end
end