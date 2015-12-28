class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :update, :destroy, :accept, :decline, :abort, :cancel ]
  before_action :set_booking_from_params, only: [:create, :show_price]
  before_filter :authenticate_user!
  # Placeholder hook for when adding cancancan/pundit authorization layer:
  #before_action :authorize_user, only: [:new,:create,:update,:accept,:decline,:abort,:cancel]

  helper SessionsHelper


  # GET /me/bookings
  def index
    @bookings = current_user.current_and_recent_bookings.map &:decorate
  end

  # GET /me/bookings/1
  def show
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
      redirect_to @booking
      notify_about_new_booking
    else
      render :new
    end
  end

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
    notify_about_accept
    redirect_to @booking
  end

  # POST /me/bookings/1/decline
  def decline
    @booking.decline!
    notify_about_decline
    redirect_to @booking
  end

  # POST /me/bookings/1/abort
  def abort
    @booking.abort!
    notify_about_abort
    redirect_to @booking
  end

  # POST /me/bookings/1/cancel
  def cancel
    @booking.cancel!
    notify_about_cancel
    redirect_to @booking
  end

  private
  # FIXME/TODO(RA): these notify_* methods belong in the model. (self.user/from_user.notification.create({}) )
  def notify_about_accept
    Notification.create(
      user_id: @booking.from_user.id,
      message: "#{@booking.user.display_name} har godkjent din forespørsel om å leie \"#{@booking.ad.display_title}\"",
      notifiable: @booking
    )
  end

  def notify_about_decline
    Notification.create(
      user_id: @booking.from_user.id,
      message: "#{@booking.user.display_name} har avslått din forespørsel om å leie \"#{@booking.ad.display_title}\"",
      notifiable: @booking
    )
  end

  def notify_about_abort
    Notification.create(
      user_id: @booking.user.id,
      message: "#{@booking.from_user.display_name} har kansellert booking forespørsel om å leie \"#{@booking.ad.display_title}\"",
      notifiable: @booking )
  end

  def notify_about_cancel
    Notification.create(
      user_id: @booking.user.id,
      message: "#{@booking.from_user.display_name} har kansellert bookingen på \"#{@booking.ad.display_title}\"",
      notifiable: @booking )
  end

  def notify_about_new_booking
    Notification.create(
      user_id: @booking.user.id,
      message: "#{@booking.from_user.display_name} ønsker å leie \"#{@booking.ad.display_title}\"",
      notifiable: @booking
    )
  end

  def notify_about_updated_booking
    Notification.create(
      user_id: @booking.user.id,
      message: "#{@booking.from_user.display_name} har oppdatert bookingen på \"#{@booking.ad.display_title}\"",
      notifiable: @booking
    )
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    # FIXME: retrict to user/from_user? (so its not public for EVERYONE)
    @booking = Booking.find_by( guid: params[:guid] ).decorate
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
end
