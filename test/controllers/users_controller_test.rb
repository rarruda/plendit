require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { ephemeral_answer_percent: @user.ephemeral_answer_percent, join_timestamp: @user.join_timestamp, last_action_timestamp: @user.last_action_timestamp, name: @user.name, phome_number: @user.phome_number, private_link_to_facebook: @user.private_link_to_facebook, private_link_to_linkedin: @user.private_link_to_linkedin }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { ephemeral_answer_percent: @user.ephemeral_answer_percent, join_timestamp: @user.join_timestamp, last_action_timestamp: @user.last_action_timestamp, name: @user.name, phome_number: @user.phome_number, private_link_to_facebook: @user.private_link_to_facebook, private_link_to_linkedin: @user.private_link_to_linkedin }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
