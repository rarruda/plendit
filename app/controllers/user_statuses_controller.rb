class UserStatusesController < ApplicationController
  before_action :set_user_status, only: [:show, :edit, :update, :destroy]

  # GET /user_statuses
  # GET /user_statuses.json
  def index
    @user_statuses = UserStatus.all
  end

  # GET /user_statuses/1
  # GET /user_statuses/1.json
  def show
  end

  # GET /user_statuses/new
  def new
    @user_status = UserStatus.new
  end

  # GET /user_statuses/1/edit
  def edit
  end

  # POST /user_statuses
  # POST /user_statuses.json
  def create
    @user_status = UserStatus.new(user_status_params)

    respond_to do |format|
      if @user_status.save
        format.html { redirect_to @user_status, notice: 'User status was successfully created.' }
        format.json { render :show, status: :created, location: @user_status }
      else
        format.html { render :new }
        format.json { render json: @user_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_statuses/1
  # PATCH/PUT /user_statuses/1.json
  def update
    respond_to do |format|
      if @user_status.update(user_status_params)
        format.html { redirect_to @user_status, notice: 'User status was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_status }
      else
        format.html { render :edit }
        format.json { render json: @user_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_statuses/1
  # DELETE /user_statuses/1.json
  def destroy
    @user_status.destroy
    respond_to do |format|
      format.html { redirect_to user_statuses_url, notice: 'User status was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_status
      @user_status = UserStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_status_params
      params.require(:user_status).permit(:status)
    end
end
