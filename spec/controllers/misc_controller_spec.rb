# spec/controllers/ads_controller_spec.rb
require 'spec_helper'
require 'rails_helper'

describe MiscController do
  before(:each) do
    allow(controller).to receive(:current_user) { FactoryGirl.create(:user) }
  end

  describe "GET #index" do
    it 'should always return 200 for the frontpage' do
      get :frontpage
      expect(response.status).to eq(200)
    end
  end
end