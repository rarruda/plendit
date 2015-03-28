class ProfileStatusesController < ApplicationController
  before_action :set_profile_status, only: [:show, :edit, :update, :destroy]

  # GET /profile_statuses
  # GET /profile_statuses.json
  def index
    @profile_statuses = ProfileStatus.all
  end

  # GET /profile_statuses/1
  # GET /profile_statuses/1.json
  def show
  end

  # GET /profile_statuses/new
  def new
    @profile_status = ProfileStatus.new
  end

  # GET /profile_statuses/1/edit
  def edit
  end

  # POST /profile_statuses
  # POST /profile_statuses.json
  def create
    @profile_status = ProfileStatus.new(profile_status_params)

    respond_to do |format|
      if @profile_status.save
        format.html { redirect_to @profile_status, notice: 'Profile status was successfully created.' }
        format.json { render :show, status: :created, location: @profile_status }
      else
        format.html { render :new }
        format.json { render json: @profile_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profile_statuses/1
  # PATCH/PUT /profile_statuses/1.json
  def update
    respond_to do |format|
      if @profile_status.update(profile_status_params)
        format.html { redirect_to @profile_status, notice: 'Profile status was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile_status }
      else
        format.html { render :edit }
        format.json { render json: @profile_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_statuses/1
  # DELETE /profile_statuses/1.json
  def destroy
    @profile_status.destroy
    respond_to do |format|
      format.html { redirect_to profile_statuses_url, notice: 'Profile status was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile_status
      @profile_status = ProfileStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_status_params
      params.require(:profile_status).permit(:status)
    end
end
