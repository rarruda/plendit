# spec/controllers/ads_controller_spec.rb
require 'spec_helper'
require 'rails_helper'

describe AdsController do
  #let(:valid_attributes) do
  #  { body: 'Tekst', title: 'foobar' }
  #end

  before(:each) do
    allow(controller).to receive(:current_user) { FactoryGirl.create(:user) }
  end

  describe "GET #show" do
    xit 'shows one ad' do

      get :show, id: 146
      expect(response.status).to eq(200)
    end
  end


  describe "GET #search" do
    xit 'performs a simple search in ElasticSearch which returns valid result' do
      expect_any_instance_of( Ad ).to receive(:search).with("").and_return(response)

      #get :autocomplete, query: '*', format: :json
      response.should be_success
    end
  end
end