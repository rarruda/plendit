require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @profile = profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, profile: { ephemeral_answer_percent: @profile.ephemeral_answer_percent, join_timestamp: @profile.join_timestamp, last_action_timestamp: @profile.last_action_timestamp, name: @profile.name, phome_number: @profile.phome_number, private_link_to_facebook: @profile.private_link_to_facebook, private_link_to_linkedin: @profile.private_link_to_linkedin }
    end

    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should show profile" do
    get :show, id: @profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile
    assert_response :success
  end

  test "should update profile" do
    patch :update, id: @profile, profile: { ephemeral_answer_percent: @profile.ephemeral_answer_percent, join_timestamp: @profile.join_timestamp, last_action_timestamp: @profile.last_action_timestamp, name: @profile.name, phome_number: @profile.phome_number, private_link_to_facebook: @profile.private_link_to_facebook, private_link_to_linkedin: @profile.private_link_to_linkedin }
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, id: @profile
    end

    assert_redirected_to profiles_path
  end
end
