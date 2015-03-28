require 'test_helper'

class BookingsControllerTest < ActionController::TestCase
  setup do
    @booking = bookings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bookings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create booking" do
    assert_difference('Booking.count') do
      post :create, booking: { ad_item_id: @booking.ad_item_id, booking_from: @booking.booking_from, booking_status_id: @booking.booking_status_id, booking_to: @booking.booking_to, first_reply_at: @booking.first_reply_at, price: @booking.price, from_profile_id: @booking.from_profile_id }
    end

    assert_redirected_to booking_path(assigns(:booking))
  end

  test "should show booking" do
    get :show, id: @booking
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @booking
    assert_response :success
  end

  test "should update booking" do
    patch :update, id: @booking, booking: { ad_item_id: @booking.ad_item_id, booking_from: @booking.booking_from, booking_status_id: @booking.booking_status_id, booking_to: @booking.booking_to, first_reply_at: @booking.first_reply_at, price: @booking.price, from_profile_id: @booking.from_profile_id }
    assert_redirected_to booking_path(assigns(:booking))
  end

  test "should destroy booking" do
    assert_difference('Booking.count', -1) do
      delete :destroy, id: @booking
    end

    assert_redirected_to bookings_path
  end
end
