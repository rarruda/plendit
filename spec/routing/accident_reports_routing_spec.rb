require "rails_helper"

RSpec.describe AccidentReportsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/accident_reports").to route_to("accident_reports#index")
    end

    it "routes to #new" do
      expect(:get => "/accident_reports/new").to route_to("accident_reports#new")
    end

    it "routes to #show" do
      expect(:get => "/accident_reports/1").to route_to("accident_reports#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/accident_reports/1/edit").to route_to("accident_reports#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/accident_reports").to route_to("accident_reports#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/accident_reports/1").to route_to("accident_reports#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/accident_reports/1").to route_to("accident_reports#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/accident_reports/1").to route_to("accident_reports#destroy", :id => "1")
    end

  end
end
