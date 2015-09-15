# spec/controllers/ads_controller_spec.rb
require 'spec_helper'
require 'rails_helper'


describe AdsController, :type => :controller do
  #let(:valid_attributes) do
  #  { body: 'Tekst', title: 'foobar' }
  #end

  before(:each) do
    allow(controller).to receive(:current_user) { FactoryGirl.build(:user) }
  end

  describe "GET #show" do
    xit 'shows one ad' do

      get :show, id: 146
      expect(response.status).to eq(200)
    end
  end



end