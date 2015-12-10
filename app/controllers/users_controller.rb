class UsersController < ApplicationController

  before_action :authenticate_user!, :except => [:show, :finish_signup]

  before_action :set_user, only: [
    :bank_account,
    :confirmation,
    :destroy,
    :edit,
    :finish_signup,
    :mark_all_notifications_noticed,
    :payment,
    :rental_history,
    :resend_verification_sms,
    :show,
    :update,
    :update_bank_account,
    :verify_sms,
  ]

  before_action :set_user_payment_account, only: [:payment, :bank_account, :update_bank_account]

  add_flash_types :sms_notice, :payment_card_notice, :payment_account_notice


  def verify_drivers_license
    if request.post?
      current_user.delete_current_drivers_license

      front = UserDocument.new(user: current_user, category: :drivers_license_front, status: :pending_approval)
      front.document = params[:front]
      front.save!

      back = UserDocument.new(user: current_user, category: :drivers_license_back, status: :pending_approval)
      back.document = params[:back]
      back.save!
    end
    @license = current_user.drivers_license
  end

  def verify_id_card
    if request.post?
      current_user.delete_current_id_card
      @card = UserDocument.new(user: current_user, category: :id_card, status: :pending_approval)
      @card.document = params[:image]
      @card.save!
    end
    @card = current_user.id_card
  end

  def verify_boat_license
    if request.post?
      current_user.delete_current_boat_license
      @card = UserDocument.new(user: current_user, category: :boat_license, status: :pending_approval)
      @card.document = params[:image]
      @card.save!
    end
    @card = current_user.boat_license
  end

  def verify_mobile
    if request.post?
      if params[:perform] == 'set_number'
        current_user.unconfirmed_phone_number = params[:phone_number]
        current_user.save
        @errors = current_user.errors
      elsif params[:perform] == 'request_token'
        if current_user.sms_sending_cool_off_elapsed?
          @errors = ['Det er for kort tid siden vi sendte deg en verifikasjonskode. Prøv igjen om litt.']
        elsif current_user.unconfirmed_phone_number.blank? || current_user.phone_number_confirmation_token.blank?
          @errors =['Ukjent telefonnumer. Kunne ikke sende verifikasjonskode. Oppdater nummeret ditt for å prøve igjen.']
        else
          current_user.send_sms_for_phone_confirmation
          current_user.save!
        end
      elsif params[:perform] == 'set_token'
        if current_user.phone_number_confirmation_token == params[:token]
          current_user.confirm_phone_number!
        else
          @errors = ["Feil sikkerhetskode!"]
        end
      end
    end
  end

  def verify_email
    if request.post?
      current_user.send_confirmation_instructions
    end
  end

  # no longer used, index now routes to private_profile
  def index
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find( params[:id] ).decorate
  end

  def private_profile
    @user = current_user
    @verifications = self.user_verifications @user
  end

  def user_verifications user
    [
      OpenStruct.new({
        title: 'Telefonnummer',
        state: user.phone_verified? ? :verified : :required,
        rejected: false,
        rejection_reason: nil,
        path: verify_mobile_users_path,
        link_text: 'Bekreft telefonnummer nå',
        question?: true

      }),
      OpenStruct.new({
        title: 'E-post',
        state: user.email_verified? ? :verified : :required,
        rejected: false,
        rejection_reason: nil,
        path: verify_email_users_path,
        link_text: 'Ikke mottatt verifiseringslink?',
        question?: true
      }),
      OpenStruct.new({
        title: 'Førerkort',
        state: user.drivers_license_status,
        rejected: user.drivers_license_status == :rejected,
        rejection_reason: user.drivers_license_rejection_reason,
        path: verify_drivers_license_users_path
      }),
      OpenStruct.new({
        title: 'Identitetsbevis',
        state: user.drivers_license_status == :verified || user.id_card_status == :verified ? :verified : user.id_card_status,
        rejected: user.id_card_status == :rejected,
        rejection_reason: user.drivers_license_rejection_reason,
        path: verify_id_card_users_path
      }),
      OpenStruct.new({
        title: 'Båtførerbevis',
        state: user.boat_license_status,
        rejected: user.boat_license_status == :rejected,
        rejection_reason: user.boat_license_rejection_reason,
        path: verify_boat_license_users_path
      })
    ]
  end

  # GET /users/1/edit
  def edit
    # required to build one user_image virtually, so that we have something to render:
    @user.user_images.build          if @user.user_images.blank?
  end

  # GET/POST /me/bank_account
  def bank_account
    if request.post?
      #@user = current_user
      if @user_payment_account.update(user_payment_account_params)
        redirect_to payment_users_path( anchor: 'kontonummer' ), payment_account_notice: 'bank account was successfully updated.'
      else
        render 'edit_user_payment_account', payment_account_notice: 'bank account was NOT saved.'
      end
    else
      render 'edit_user_payment_account'
    end
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

    # TODO: move this code to its own method.
    # cleaner solution suggestion: http://stackoverflow.com/a/20533963/2455161
    user_params_safe = user_params
    if @user.phone_number != user_params['current_phone_number']
      user_params_safe['unconfirmed_phone_number'] = user_params['current_phone_number']
    else
      user_params_safe['unconfirmed_phone_number'] = nil
    end
    user_params_safe.except!('current_phone_number')


    if @user.update(user_params_safe)
      # annoying that we have to save first up there and then save again below: #@user.user_images.avatar.empty?
      if not @user.user_images.avatar.first.image_file_name.blank?
        @user.image_url = @user.user_images.avatar.first.image.url(:avatar_huge)
        @user.save
      end
      redirect_to ( request.env['HTTP_REFERER'] || users_edit_path )
    else
      render :edit
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
        sign_in(@user, bypass: true)
        redirect_to private_profile_users_path
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

  # GET /me/payment
  def payment
    @user_payment_cards = current_user.user_payment_cards.sort
  end

  # GET /me/payment/payout
  def payout
    payout_wallet_balance = current_user.fetch_payout_wallet_balance

    if request.post? && current_user.user_payment_account.present?
      current_user.user_payment_account.create_financial_transaction_payout( payout_wallet_balance )
      redirect_to payment_users_path( anchor: 'transaction_history' ), payment_account_notice: 'Utbetaling ble opprettet.'
    end

    if current_user.user_payment_account.present?
      @financial_transaction_payout = current_user.user_payment_account.build_financial_transaction_payout( payout_wallet_balance )
    else
      @financial_transaction_payout = current_user.build_user_payment_account.build_financial_transaction_payout( payout_wallet_balance )
    end
  end

  # GET /me/rental_history
  def rental_history
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
      params.require(:user).permit(:first_name, :last_name, :birthday,
        :email, :about,
        :personhood, :nationality, :country_of_residence,
        :home_address_line, :home_post_code,
        :password, :password_confirmation,
        :current_phone_number, :phone_number_confirmation_token,
         user_images_attributes: [:id, :image, :category],
         identity_attributes: [:provider]
      )
    end

    def set_user_payment_account
      @user_payment_account = current_user.user_payment_account || current_user.build_user_payment_account
    end

    def user_payment_account_params
      params.require(:user_payment_account).permit(:bank_account_number) || nil
    end
end