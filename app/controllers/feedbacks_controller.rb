class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :update, :destroy]

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all.decorate
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    @feedback.decorate
  end

  # GET /feedbacks/new
  def new
    # Note: this will be a proper feedback object, but that needs to be
    # refactored a bit once we decide how they are supposed to work.
    # IOW this is just random objects used for writing some html that
    # will be needed regardless of behaviour.
    # Perhaps /me/booking/<guid>/give_feedback ?
    @ad = Ad.find_by(status: 2).decorate
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.from_user = current_user

    respond_to do |format|
      if @feedback.save
        format.html { redirect_to booking_path(@feedback.booking) }
        format.json { render :show, status: :created, location: @feedback }
      else
        format.html { render :new }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feedbacks/1
  # PATCH/PUT /feedbacks/1.json
  def update
    if @feedback.update(feedback_params)
      redirect_to booking_path(@feedback.booking), notice: 'Takk for tilbakemeldingen!'
    else
      redirect_to booking_path(@feedback.booking), notice: 'Klarte ikke å lagre tilbakemeldingen. Prøv igjen senere.'
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback.destroy
    respond_to do |format|
      format.html { redirect_to feedbacks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @booking  = Booking.find_by_guid params[:guid]
      @feedback = @booking.feedbacks.from_user(current_user).take
    end

    def feedback_params
      params.require(:feedback).permit(:booking_id, :score, :body)
    end
end
