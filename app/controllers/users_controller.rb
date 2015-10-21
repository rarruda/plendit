class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :finish_signup, :upload_drivers_license, :verify_drivers_license]
  before_action :set_user, only: [
    :show, :edit, :update, :destroy, :confirmation,
    :verify_sms, :verify_sms, :mark_all_notifications_noticed,
    :resend_verification_sms
  ]

  add_flash_types :sms_notice


  def verify_drivers_license
    @license = current_user.drivers_license
  end

  def upload_drivers_license
    current_user.delete_current_drivers_license

    front = UserDocument.new(user: current_user, category: :drivers_license_front, status: :pending_approval)
    front.document = params[:front]
    front.save!

    back = UserDocument.new(user: current_user, category: :drivers_license_back, status: :pending_approval)
    back.document = params[:back]
    back.save!

    @license = current_user.drivers_license
    render :verify_drivers_license
  end

  def verify_id_card
    @card = current_user.id_card
  end

  def upload_id_card
    current_user.delete_current_id_card
    @card = UserDocument.new(user: current_user, category: :id_card, status: :pending_approval)
    @card.document = params[:image]
    @card.save!
    render :verify_id_card
  end


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
    @user = User.find( params[:id] ).decorate
  end

  def private_profile
    @user = current_user
  end


  # GET /users/1/edit
  def edit
    # required to build one user_payment_account/user_image virtually, so that we have something to render:
    @user.build_user_payment_account if @user.user_payment_account.nil?
    @user.user_images.build          if @user.user_images.blank?
  end

  # Never gets called, as users are created in users/registrations_controller
  # FIXME: remove the create method.
  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Bruker opprettet.' }
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

    # FIXME: user_payment_account / bank_account_number is NEVER updated.
    #@user.build_user_payment_account if @user.user_payment_account.nil?

    # TODO: move this code to its own method.
    user_params_safe = user_params
    if @user.phone_number != user_params['current_phone_number']
      user_params_safe['unconfirmed_phone_number'] = user_params['current_phone_number']
    else
      user_params_safe['unconfirmed_phone_number'] = nil
    end
    user_params_safe.except!('current_phone_number')


    respond_to do |format|
      if @user.update(user_params_safe)
        # annoying that we have to save first up there and then save again below: #@user.user_images.avatar.empty?
        if not @user.user_images.avatar.first.image_file_name.blank?
          @user.image_url = @user.user_images.avatar.first.image.url(:avatar_huge)
          @user.save
        end

        format.html { redirect_to ( request.env['HTTP_REFERER'] || users_edit_path ) }
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
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # DELETE /me/identity
  def destroy_identity
    if current_user.identities.find_by(provider: params[:user][:identity][:provider]).destroy!
      redirect_to :back, notice: "disconnected your account from #{params[:user][:identity][:provider]}"
    else
      redirect_to :back, notice: "failed disconnecting your account from #{params[:user][:identity][:provider]}"
    end
  rescue ActionController::RedirectBackError
    redirect_to edit_users_path #( anchor: 'identities' )
  end

  # FIXME: eventually we should support deleting avatars.

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

  # POST /me/verify_sms
  def verify_sms
    if @user.phone_number_confirmation_token == user_params['phone_number_confirmation_token'] &&
       @user.confirm_phone_number!
      redirect_to edit_users_path, notice: 'Mobilnummeret ditt er verifisert.'
    else
      redirect_to edit_users_path, sms_notice: 'Mobilnummeret ble IKKE verifisert. Kontroler koden og forsøk igjen. Du må kanskje få tilsendt en ny kode.'
    end
  end

  # POST /me/resend_verification_sms
  def resend_verification_sms
    if ! @user.sms_sending_cool_off_elapsed?
      redirect_to edit_users_path, sms_notice: 'Det er for kort tid siden vi sendte deg en verifikasjonskode. Prøv igjen om litt.'
    elsif @user.unconfirmed_phone_number.blank? || @user.phone_number_confirmation_token.blank?
      redirect_to edit_users_path, notice: 'Ukjent telefonnumer. Kunne ikke sende verifikasjonskode. Oppdater nummeret ditt for å prøve igjen.'
    else
      @user.send_sms_for_phone_confirmation
      @user.save!

      redirect_to edit_users_path, sms_notice: 'En verifikasjonskode er sendt til din telefon.'
    end
  end

  # POST /mark_all_notifications_noticed
  def mark_all_notifications_noticed
    @user.notifications
         .where(status: 'fresh')
         .update_all(status: Notification.statuses[:noticed])
    head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      # Use preferably the user_id in the URL. Otherwise fall back to user_id of
      # the logged in user. Note sure this is super wise.
      @user = ( params[:id] ? User.find( params[:id] ) : current_user )
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :birthday, :email,
        :personhood, :nationality, :country_of_residence,
        :home_address_line, :home_post_code,
        :password, :password_confirmation,
        :current_phone_number, :phone_number_confirmation_token,
         user_payment_account_attributes: [:id, :bank_account_number],
         user_images_attributes: [:id, :image, :category],
         identity_attributes: [:provider]
      )
    end
end
