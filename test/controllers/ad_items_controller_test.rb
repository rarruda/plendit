require 'test_helper'

class AdItemsControllerTest < ActionController::TestCase
  setup do
    @ad_item = ad_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ad_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ad_item" do
    assert_difference('AdItem.count') do
      post :create, ad_item: { ad_id: @ad_item.ad_id }
    end

    assert_redirected_to ad_item_path(assigns(:ad_item))
  end

  test "should show ad_item" do
    get :show, id: @ad_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ad_item
    assert_response :success
  end

  test "should update ad_item" do
    patch :update, id: @ad_item, ad_item: { ad_id: @ad_item.ad_id }
    assert_redirected_to ad_item_path(assigns(:ad_item))
  end

  test "should destroy ad_item" do
    assert_difference('AdItem.count', -1) do
      delete :destroy, id: @ad_item
    end

    assert_redirected_to ad_items_path
  end
end
