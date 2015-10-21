# spec/controllers/users_controller_spec.rb
require 'spec_helper'
require 'rails_helper'

describe UsersController do

  describe "GET #index" do
    it 'should always return 200 for the post login landing page' do
      current_user = FactoryGirl.build(:user)
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)

      get :index
      expect(response.status).to eq(200)
    end
  end

  describe "DELETE #identity" do
    it 'should delete a given identity' do
      current_user = FactoryGirl.build(:user_with_identity)

      to_be_deleted_identity = current_user.identities.select{|k,v| k == 'provider' && v == 'google' }

      # devise:
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)

      # request:
      delete :destroy_identity, {user: {identity: { provider: 'google'} } }

      # data change happens:
      expect(current_user.identities).not_to include{ to_be_deleted_identity }
    end

    it 'should once deleted a given identity to redirect back' do
      current_user = FactoryGirl.build(:user_with_identity)

      # referrer (for redirecting back from original form url):
      request.env['HTTP_REFERER'] = 'foo'

      # devise:
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)

      # request:
      delete :destroy_identity, {user: {identity: { provider: 'google'} } }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('foo')
    end

    it 'should redirect to login page if user is not logged in' do
      delete :destroy_identity, {provider: 'google'}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

end