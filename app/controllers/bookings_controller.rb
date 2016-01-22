class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update, :destroy, :accept, :decline, :abort, :cancel ]
  before_action :set_booking_from_params, only: [:create, :show_price]
  before_filter :authenticate_user!
  # Placeholder hook for when adding cancancan/pundit authorization layer:
  #before_action :authorize_user, only: [:new,:create,:update,:accept,:decline,:abort,:cancel]

  # when called with 'callback' parameter, then its a callback, and refresh booking accordingly.
  before_action :booking_callback_refresh, only: [:show], if: "params['callback'].present?"

  helper SessionsHelper


  # GET /me/bookings
  def index
    @bookings = current_user.current_and_recent_bookings.map &:decorate
  end

  # GET /me/bookings/1
  def show
    # show 404 unless booking was found
    render(file: "#{Rails.root}/public/404.html", layout: false, status: 404) if @booking.nil?
  end

  # GET /me/bookings/new
  def new
    @ad = Ad.find( params['ad_id'] ).decorate
    @booking = Booking.new( ad: @ad, from_user: current_user ).decorate
  end

  # POST /me/bookings
  def create
    @ad = AdItem.find(booking_params[:ad_item_id]).ad.decorate

    if @booking.save
      redirect_to ( (@booking.secure_mode_needed && @booking.secure_mode_redirect_url.present? ) ?
        @booking.secure_mode_redirect_url : booking_path(@booking, callback: true)
      )
    else
      render :new
    end
  end

  # NOTE: only editable field is :deposit_offer_amount
  # PATCH /me/bookings/1
  def update
    @booking.update(booking_offer_params) if @booking.may_set_deposit_offer_amount?(current_user)

    render :show
  end

  # GET /me/bookings/1/booking_calc
  def booking_calc
    ad_id = params[:ad_id]
    from  = params[:from_date]
    to    = params[:to_date]

    @booking = Booking.new(ad_item_id: Ad.find(ad_id).ad_items.take.id, starts_at_date: from, ends_at_date: to)
    @booking.calculate!
    @booking.readonly!

    respond_to do |format|
      format.html { render partial: 'price_summary' }
      format.json { render json: show_price, status: :ok }
    end
  end

  # GET /me/bookings/show_price
  def show_price
    @booking.calculate_amount
    respond_to do |format|
      format.html { render :show_price } #redirect_to @booking, notice: 'Booking was successfully updated.' }
      format.json { render json: show_price, status: :ok }
    end
  end

  # POST /me/bookings/1/accept
  def accept
    @booking.confirm!
    redirect_to @booking
  end

  # POST /me/bookings/1/decline
  def decline
    @booking.decline!
    redirect_to @booking
  end

  # POST /me/bookings/1/abort
  def abort
    @booking.abort!
    redirect_to @booking
  end

  # POST /me/bookings/1/cancel
  def cancel
    @booking.cancel!
    redirect_to @booking
  end

  private

  # if its a callback, we trigger a refresh from mangopay.
  # GET /me/bookings/1?preAuthorizationId=2
  def booking_callback_refresh
    @booking.refresh!
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    # FIXME: retrict to user/from_user? (so its not public for EVERYONE) (via pundit gem)
    begin
      # use bang to raise exception
      @booking = Booking.find_by_guid!(params[:guid]).decorate
    rescue ActiveRecord::RecordNotFound => e
      @booking = nil
    end
  end

  def set_booking_from_params
    new_booking = booking_params.merge( {
      'from_user_id' => current_user.id,
      'status'       => 'created',
      'user_payment_card_id' => current_user.user_payment_cards.find_by(guid: booking_params[:user_payment_card_id]).id
    } )

    @booking = Booking.new( new_booking ).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def booking_params
    params.require(:booking).permit(
      :ad_item_id, :starts_at, :ends_at, :ends_at_date,
      :ends_at_time, :starts_at_date, :starts_at_time, :status,
      :user_payment_card_id
    )
  end

  def booking_offer_params
    params.require(:booking).permit(:deposit_offer_amount_in_h)
  end
end
