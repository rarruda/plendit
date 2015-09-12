# spec/controllers/ads_controller_spec.rb
require 'spec_helper'
require 'rails_helper'

describe AdsController do
  #let(:ad) { Ad.make!(body:'foo', price: 32111 ) }

  #let(:valid_attributes) do
  #  { body: 'Tekst', title: 'foobar' }
  #end

  describe "GET #search" do
    xit 'performs a simple search in ElasticSearch which returns valid result' do
      expect_any_instance_of( Ad ).to receive(:search).with("").and_return(response)

      #get :autocomplete, query: '*', format: :json
      response.should be_success
    end
  end
end