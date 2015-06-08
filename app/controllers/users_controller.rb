class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :confirmation, :verify_sms, :do_verify_sms]
  before_filter :authenticate_user!, :except => [:show, :finish_signup]

  def index
  end

  # GET /users/1
  # GET /users/1.json
  def requests
    @sent_requests = [
      {id: 1, title: "testlink 1", path: "#requestpath"},
      {id: 2, title: "testlink 2", path: "#requestpath"},
      {id: 3, title: "testlink 3", path: "#requestpath"},
      {id: 4, title: "testlink 4", path: "#requestpath"},
      {id: 5, title: "testlink 5", path: "#requestpath"},
      {id: 6, title: "testlink 6", path: "#requestpath"}
    ]
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find( params[:id] )
  end


  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # TODO: move this code to its own method.
    user_params_safe = user_params
    if @user.phone_number != user_params['current_phone_number']
      user_params_safe['unconfirmed_phone_number'] = user_params['current_phone_number']
    end
    user_params_safe.except!('current_phone_number')

    respond_to do |format|
      if @user.update(user_params_safe)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    # authorize! :update, @user
    if request.patch? && params[:user] #&& params[:user][:email]
      if @user.update(user_params)
        @user.skip_reconfirmation!
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  # GET /verify_sms
  def verify_sms
    # if user already has phone verified, take him somewhere else.
    unless @user.phone_pending_confirmation?
      redirect_to @user, notice: 'Your phone_number was already verified. no need to try to verify it again.'
    end
  end

  # POST /verify_sms
  def do_verify_sms
    if @user.phone_number_confirmation_token == user_params['phone_number_confirmation_token'] and
       @user.confirm_phone_number!
      redirect_to @user, notice: 'Your phone_number was successfully verified.'
    else
      redirect_to @user, notice: 'Your phone_number was NOT verified, please check the code, and try again. Eventually try resending a new verification code.'
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find( view_context.get_current_user_id )
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :current_phone_number, :user_status_id, :password, :password_confirmation, :phone_number_confirmation_token)
    end
end
