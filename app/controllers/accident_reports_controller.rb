class AccidentReportsController < InheritedResources::Base

  # GET /me/accident_report
  def index
    @accident_report = AccidentReport.new( from_user_id: current_user.id )
    @bookings = Booking.accidents_reportable.has_user( current_user ).all
  end

  def show
  end

  # POST /me/accident_report
  def create
    @accident_report = AccidentReport.new(
      accident_report_params
      .except( :booking_guid )
      .merge(
        from_user_id: current_user.id,
        booking_id:   Booking.find_by(guid: accident_report_params[:booking_guid] ).id
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
      params.require(:accident_report).permit(:booking_guid, :from_user, :happened_at, :location_address_line, :location_post_code, :location_country, :body)
    end
end

