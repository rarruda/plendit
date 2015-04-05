class BookingStatusesController < ApplicationController
  before_action :set_booking_status, only: [:show, :edit, :update, :destroy]
  skip_before_filter :authorize

  # GET /booking_statuses
  # GET /booking_statuses.json
  def index
    @booking_statuses = BookingStatus.all
  end

  # GET /booking_statuses/1
  # GET /booking_statuses/1.json
  def show
  end

  # GET /booking_statuses/new
  def new
    @booking_status = BookingStatus.new
  end

  # GET /booking_statuses/1/edit
  def edit
  end

  # POST /booking_statuses
  # POST /booking_statuses.json
  def create
    @booking_status = BookingStatus.new(booking_status_params)

    respond_to do |format|
      if @booking_status.save
        format.html { redirect_to @booking_status, notice: 'Booking status was successfully created.' }
        format.json { render :show, status: :created, location: @booking_status }
      else
        format.html { render :new }
        format.json { render json: @booking_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /booking_statuses/1
  # PATCH/PUT /booking_statuses/1.json
  def update
    respond_to do |format|
      if @booking_status.update(booking_status_params)
        format.html { redirect_to @booking_status, notice: 'Booking status was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking_status }
      else
        format.html { render :edit }
        format.json { render json: @booking_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /booking_statuses/1
  # DELETE /booking_statuses/1.json
  def destroy
    @booking_status.destroy
    respond_to do |format|
      format.html { redirect_to booking_statuses_url, notice: 'Booking status was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking_status
      @booking_status = BookingStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_status_params
      params.require(:booking_status).permit(:status)
    end
end
