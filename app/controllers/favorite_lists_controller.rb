class FavoriteListsController < ApplicationController
  before_action :set_favorite_list, only: [:show, :preview, :edit, :update, :destroy]


  # GET /favorite_lists
  # GET /favorite_lists.json
  def index
    @favorite_lists = FavoriteList.where( user_id: view_context.get_current_user_id ).all
  end

  # POST /favorite_lists
  # POST /favorite_lists.json
  def create
    @favorite_lists = FavoriteList.new(favorite_list_params)
    @favorite_lists.user_id = view_context.get_current_user_id

    respond_to do |format|
      if @favorite_lists.save
        format.html { redirect_to favorite_lists_path(:favorite_lists_id => @favorite_lists.id), notice: 'Ad was successfully created.' }
        format.json { render :show, status: :created, location: @favorite_lists }
      else
        format.html { render :new }
        format.json { render json: @favorite_lists.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite_list
      @favorite_list = FavoriteList.find(params[:id])
    end

    def favorite_list_params
      #params.require(:favorite_list).permit(:user_id, :name)
      params.require(:favorite_list).permit(:name)
    end
end

