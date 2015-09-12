class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy, :decline, :cancel, :accept]
  before_action :set_booking_from_params, only: [:create, :show_price]
  before_filter :authenticate_user!

  helper SessionsHelper


  # GET /bookings
  # GET /bookings.json
  def index
    # fixme: use merged list of sent and received for current user
    @bookings = Booking.owner_user(current_user)
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @ad = Ad.find( params['ad_id'] ).decorate
    @booking = Booking.new( ad: @ad ).decorate
  end

  # GET /bookings/1/edit
  def edit
    @ad = @booking.ad
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @ad = AdItem.find(booking_params[:ad_item_id]).ad

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking }
        format.json { render :show, status: :created, location: @booking }
        notify_about_new_booking
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    #if current_user == @booking.from_user
    #  raise 'permission denied' if not ['cancelled','accepted'].include? booking_params.status
    #elsif current_user == @booking.user
    #  raise 'permission denied' if booking_params.status != 'declined'
    #end

    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking }
        format.json { render :show, status: :ok, location: @booking }
        notify_about_updated_booking
      else
        @ad = @booking.ad
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end


  # GET /bookings/show_price
  # GET /bookings/show_price.json
  def show_price
    @booking.calculate_amount
    respond_to do |format|
      format.html { render :show_price } #redirect_to @booking, notice: 'Booking was successfully updated.' }
      format.json { render json: show_price, status: :ok }
    end
  end


  # POST /bookings/1/decline
  def decline
    @booking.decline!
    notify_about_decline
    redirect_to @booking
  end

  # POST /bookings/1/accept
  def accept
    @booking.accept!
    notify_about_accept
    redirect_to @booking
  end

  # POST /bookings/1/cancel
  def cancel
    @booking.cancel!
    notify_about_cancel
    redirect_to @booking
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id]).decorate
    end

    def set_booking_from_params
      new_booking = booking_params.merge( {
        'from_user_id' => current_user.id,
        'status'       => 'created'
      })

      @booking = Booking.new( new_booking )
    end

    def notify_about_decline
      Notification.new(
        user_id: @booking.from_user.id,
        message: "#{@booking.user.safe_display_name} har avslått din forespørsel om å leie \"#{@booking.ad.safe_title}\"",
        notifiable: @booking ).save
    end

    def notify_about_accept
      Notification.new(
        user_id: @booking.from_user.id,
        message: "#{@booking.user.safe_display_name} har godkjent din forespørsel om å leie \"#{@booking.ad.safe_title}\"",
        notifiable: @booking ).save
    end

    def notify_about_cancel
      Notification.new(
        user_id: @booking.user.id,
        message: "#{@booking.from_user.safe_display_name} har kansellert bookingen på \"#{@booking.ad.safe_title}\"",
        notifiable: @booking ).save
    end

    def notify_about_new_booking
      Notification.new(
        user_id: @booking.user.id,
        message: "#{@booking.from_user.safe_display_name} ønsker å leie \"#{@booking.ad.safe_title}\"",
        notifiable: @booking ).save
    end

    def notify_about_updated_booking
      Notification.new(
        user_id: @booking.user.id,
        message: "#{@booking.from_user.safe_display_name} har oppdatert bookingen på \"#{@booking.ad.safe_title}\"",
        notifiable: @booking ).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(
        :ad_item_id, :starts_at, :ends_at, :ends_at_date,
        :ends_at_time, :starts_at_date, :starts_at_time, :status
      )
    end
end
