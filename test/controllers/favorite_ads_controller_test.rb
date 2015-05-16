require 'test_helper'

class FavoriteAdsControllerTest < ActionController::TestCase
  setup do
    @favorite_ad = favorite_ads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:favorite_ads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create favorite_ad" do
    assert_difference('FavoriteAd.count') do
      post :create, favorite_ad: { ad_id: @favorite_ad.ad_id, favorite_list_id: @favorite_ad.favorite_list_id }
    end

    assert_redirected_to favorite_ad_path(assigns(:favorite_ad))
  end

  test "should show favorite_ad" do
    get :show, id: @favorite_ad
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @favorite_ad
    assert_response :success
  end

  test "should update favorite_ad" do
    patch :update, id: @favorite_ad, favorite_ad: { ad_id: @favorite_ad.ad_id, favorite_list_id: @favorite_ad.favorite_list_id }
    assert_redirected_to favorite_ad_path(assigns(:favorite_ad))
  end

  test "should destroy favorite_ad" do
    assert_difference('FavoriteAd.count', -1) do
      delete :destroy, id: @favorite_ad
    end

    assert_redirected_to favorite_ads_path
  end
end
