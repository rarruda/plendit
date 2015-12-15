class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy, :make_favorite]
  before_filter :authenticate_user!


  # GET /locations
  # GET /locations.json
  def index
    redirect_to edit_users_path
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.json
  def create
    # user_id should come from session, not from form!
    @location = Location.new(location_params)
    @location.user_id = view_context.get_current_user_id

    if @location.save
      redirect_to edit_users_path(:anchor => 'locations'), notice: 'Location was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    if @location.update(location_params)
      redirect_to edit_users_path(:anchor => 'locations'), notice: 'Location was successfully updated.'
    else
      render :edit
    end
  end

  # POST /locations/make_favorite/1
  def make_favorite
    current_user.set_favorite_location(@location)

    redirect_to edit_users_path(:anchor => 'locations')
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.delete! unless @location.in_use?

    redirect_to edit_users_path(:anchor => 'locations')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.where(user_id: view_context.get_current_user_id ).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:address_line, :city, :state, :post_code, :favorite)
    end
end
