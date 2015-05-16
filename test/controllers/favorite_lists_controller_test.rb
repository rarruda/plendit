require 'test_helper'

class FavoriteListsControllerTest < ActionController::TestCase
  setup do
    @favorite_list = favorite_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:favorite_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create favorite_list" do
    assert_difference('FavoriteList.count') do
      post :create, favorite_list: { name: @favorite_list.name, user_id: @favorite_list.user_id }
    end

    assert_redirected_to favorite_list_path(assigns(:favorite_list))
  end

  test "should show favorite_list" do
    get :show, id: @favorite_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @favorite_list
    assert_response :success
  end

  test "should update favorite_list" do
    patch :update, id: @favorite_list, favorite_list: { name: @favorite_list.name, user_id: @favorite_list.user_id }
    assert_redirected_to favorite_list_path(assigns(:favorite_list))
  end

  test "should destroy favorite_list" do
    assert_difference('FavoriteList.count', -1) do
      delete :destroy, id: @favorite_list
    end

    assert_redirected_to favorite_lists_path
  end
end
