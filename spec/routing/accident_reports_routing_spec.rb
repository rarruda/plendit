require "rails_helper"

RSpec.describe AccidentReportsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/me/accident_reports").to route_to("accident_reports#index")
    end

    it "routes to #create" do
      expect(:post => "/me/accident_reports").to route_to("accident_reports#create")
    end
  end
end
