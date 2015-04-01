require 'test_helper'

class MiscControllerTest < ActionController::TestCase
  test "should get frontpage" do
    get :frontpage
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end
