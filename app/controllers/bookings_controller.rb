class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  after_action  :notify_user, only: [:create, :update]
  before_filter :authenticate_user!

  helper SessionsHelper


  # GET /bookings
  # GET /bookings.json
  def index
    # fixme: use merged list of sent and received for current user
    @bookings = Booking.all
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @ad = Ad.find( params['ad_id'])
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create

    # This should be moved to its own method/helper/etc
    b_start = view_context.parse_datetime_params booking_params, 'booking_from'
    b_end = view_context.parse_datetime_params booking_params, 'booking_to'
    num_days_rented_ceil  = ( ( (b_start.to_time - b_end.to_time) / 60*60 ) % 24 ).ceil

    #price = #needs to be calculated.
    user_id = view_context.get_current_user_id
    new_booking = booking_params.merge( {
      'from_user_id'      => view_context.get_current_user_id,
      'booking_status_id' => 1,
      'price'             => @booking.ad.price * num_days_rented_ceil
    } )

    @booking = Booking.new( new_booking )

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
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
      format.html { redirect_to bookings_url, notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Callback to notify the relevant parties that the booking is in place.
    # TODO: check that we can take for granted that @booking is in place.
    # TODO: more fine grained notifications needed:
    #   Accepting, rejecting, canceling and editing a booking request
    # TODO: move to aasm
    def notify_user
      Notification.new(
        user_id: @booking.user.id,
        message: "Somone has booked (wants to rent) a item you own: #{@booking.ad.id}",
        notifiable: @booking ).save
      Notification.new(
        user_id: @booking.from_user.id,
        message: "A booking request has been created for you.",
        notifiable: @booking ).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:ad_item_id, :booking_from, :booking_to)
    end
end
