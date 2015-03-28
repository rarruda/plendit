require 'test_helper'

class ProfileStatusesControllerTest < ActionController::TestCase
  setup do
    @profile_status = profile_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profile_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile_status" do
    assert_difference('ProfileStatus.count') do
      post :create, profile_status: { status: @profile_status.status }
    end

    assert_redirected_to profile_status_path(assigns(:profile_status))
  end

  test "should show profile_status" do
    get :show, id: @profile_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile_status
    assert_response :success
  end

  test "should update profile_status" do
    patch :update, id: @profile_status, profile_status: { status: @profile_status.status }
    assert_redirected_to profile_status_path(assigns(:profile_status))
  end

  test "should destroy profile_status" do
    assert_difference('ProfileStatus.count', -1) do
      delete :destroy, id: @profile_status
    end

    assert_redirected_to profile_statuses_path
  end
end
