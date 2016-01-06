class AccidentReportsController < InheritedResources::Base
  before_action :authenticate_user!

  # GET /me/bookings/:booking_guid/accident_report
  def index
    @booking = Booking.find_by(guid: params[:booking_guid]).decorate
    @accident_report = AccidentReport.new(
      from_user_id: current_user.id,
      booking: @booking
    )
  end

  # POST /me/bookings/:booking_guid/accident_report
  def create
    @booking = Booking.find_by(guid: params[:booking_guid]).decorate
    @accident_report = AccidentReport.new(
      accident_report_params
      .merge(
        from_user_id: current_user.id,
        booking: @booking
      )
    )

    if @accident_report.save
      render :create
      #redirect_to users_path #redirect to the correct place if the accident report was correctly created.
    else
      @bookings = Booking.accidents_reportable.has_user( current_user ).all
      #redirect_to users_accident_reports_path, alert: "Skademelding kunne ikke opprettes!"
      render :index
    end
  end

  private
  def accident_report_params
    params
      .require(:accident_report)
      .permit(:happened_at, :location_line, :body,
              attachments: [] )
  end
end

