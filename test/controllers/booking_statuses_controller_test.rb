require 'test_helper'

class BookingStatusesControllerTest < ActionController::TestCase
  setup do
    @booking_status = booking_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:booking_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create booking_status" do
    assert_difference('BookingStatus.count') do
      post :create, booking_status: { status: @booking_status.status }
    end

    assert_redirected_to booking_status_path(assigns(:booking_status))
  end

  test "should show booking_status" do
    get :show, id: @booking_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @booking_status
    assert_response :success
  end

  test "should update booking_status" do
    patch :update, id: @booking_status, booking_status: { status: @booking_status.status }
    assert_redirected_to booking_status_path(assigns(:booking_status))
  end

  test "should destroy booking_status" do
    assert_difference('BookingStatus.count', -1) do
      delete :destroy, id: @booking_status
    end

    assert_redirected_to booking_statuses_path
  end
end
