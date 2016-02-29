class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:show, :finish_signup]

  before_action :finish_signup!, except: [:show, :finish_signup]

  before_action :set_user, only: [
    :bank_account,
    :confirmation,
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

  # GET/POST verify/drivers_license
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

  # GET/POST verify/id_card
  def verify_id_card
    if request.post?
      current_user.delete_current_id_card
      @card = UserDocument.new(user: current_user, category: :id_card, status: :pending_approval)
      @card.document = params[:image]
      @card.save!
    end
    @card = current_user.id_card
  end

  # GET/POST verify/boat_license
  def verify_boat_license
    @notices = []
    if request.post?

      # FIXME!! these two validations below belong in the model, not in the controller!
      if current_user.boat_license_required? && (!params.key? :image)
        @notices.push "Bilde mangler."
      end

      if params[:seaworthy] != "1"
        @notices.push "Du må akseptere egenærklæringen."
      end

      if @notices.empty?
        current_user.delete_current_boat_license
        current_user.seamanship_claimed = true
        current_user.save
        if current_user.boat_license_required?
          @card = UserDocument.new(user: current_user, category: :boat_license, status: :pending_approval)
          @card.document = params[:image]
          @card.save!
        end
      end

    end
    @card = current_user.boat_license
  end

  # FIXME: need to flush some logic down to the model.
  # GET/POST verify/mobile
  def verify_mobile
    if request.post?
      if params[:perform] == 'set_number'
        current_user.unconfirmed_phone_number = params[:phone_number]
        current_user.save
        @notices = current_user.errors
      elsif params[:perform] == 'request_token'
        if current_user.sms_sending_cool_off_elapsed?
          @notices = ['Det ble nydelig sendt en SMS. Prøv igjen om litt.']
        elsif current_user.unconfirmed_phone_number.blank? || current_user.phone_number_confirmation_token.blank?
          @notices = ['Ukjent telefonnumer. Kunne ikke sende verifikasjonskode. Oppdater nummeret ditt for å prøve igjen.']
        else
          current_user.send_sms_for_phone_confirmation
          current_user.save!
        end
      elsif params[:perform] == 'set_token'
        if current_user.phone_number_confirmation_token == params[:token]
          current_user.confirm_phone_number!
        else
          @notices = ["Feil sikkerhetskode!"]
        end
      end
    end
  end

  # GET/POST verify/email
  def verify_email
    if request.post?
      current_user.send_confirmation_instructions
    end
  end

  # public profile
  # GET /user/1
  def show
    @user = User.find( params[:id] ).decorate
  end

  # index now routes to private_profile
  # GET /me
  def private_profile
    @user = current_user
    @documentation = self.user_documentation @user
    @verification = self.user_verification @user
  end

  def user_verification user
    [
      OpenStruct.new({
        title: 'Telefonnummer',
        preverify_prose: %q(
          For at du skal kunne legge ut annonser eller leie
          noe på Plendit, må telefonnummeret ditt godkjennes.
         Klikk på på verifiser-lenken for å verifisere telefonnummeret ditt.
        ),
        preverify_action: 'Verifiser',
        postverify_prose: 'Telefonnummer er verifisert.',
        state: user.phone_verified? ? :verified : :missing,
        path: verify_mobile_users_path,
      }),
      OpenStruct.new({
        title: 'E-post',
        preverify_prose: %q(
          For at du skal kunne legge ut annonser eller leie
          noe på Plendit så må e-post adressen din godkjennes.
          Vi har sendt deg en epost. Hvis du ikke har mottatt den
          kan du trykke på "verifiser" lenken for å få tilsendt
          en ny.
        ),
        preverify_action: 'Verifiser',
        postverify_prose: 'E-post er verifisert.',
        state: user.email_verified? ? :verified : :missing,
        rejection_reason: nil,
        path: verify_email_users_path,
      })
    ]
  end

  def user_documentation user
    [
      OpenStruct.new({
        title: 'Førerkort',
        preverify_prose: user.drivers_license_allowed? ? %q(
          For at du skal kunne leie kjøretøy på Plendit må ditt
          førerkort godkjennes. Du må har hatt førerkort i minimum 3 år.
        ) :
        %q(
          Det er kun mulig å leie bil om du er 23 år og har hatt førerkort i minimum 3 år.
        ),
        preverify_action: 'Last opp',
        postverify_prose: 'Førerkort er godkjent.',
        pending_prose: 'Til kontroll.',
        rejected_prose: 'Ikke godkjent.',
        state: user.drivers_license_allowed? ? user.drivers_license_status : :too_young,
        rejection_reason: user.drivers_license_rejection_reason,
        path: verify_drivers_license_users_path
      }),
      OpenStruct.new({
        title: 'Identitetsbevis',
        preverify_prose: %q(
          For å leie noe på Plendit må et gyldig
          identitetsbevis med personnummer godkjennes.
          Førerkort vil automatisk gjelde som identitetsbevis.
        ),
        preverify_action: 'Last opp',
        postverify_prose: 'ID-kort er godkjent.',
        pending_prose: 'Til kontroll.',
        rejected_prose: 'Ikke godkjent.',
        state: user.has_confirmed_id? ? :verified : user.id_card_status,
        rejection_reason: user.drivers_license_rejection_reason,
        path: verify_id_card_users_path
      }),
      OpenStruct.new({
        title: 'Båtførerbevis',
        preverify_prose: %q(
          For at du skal kunne leie en båt med seil eller motor på Plendit, må du være født før 1980 eller laste opp ditt båtførerbevis.
        ),
        preverify_action: 'Last opp',
        postverify_prose: 'Båtførerbevis godkjent.',
        pending_prose: 'Til kontroll.',
        rejected_prose: 'Ikke godkjent.',
        state: user.boat_rental_allowed? ? :verified : user.boat_license_status,
        rejection_reason: user.boat_license_rejection_reason,
        path: verify_boat_license_users_path
      })
      # todo: Add payment card.
    ]
  end

  # GET /me/edit
  def edit
    # required to build one user_image virtually, so that we have something to render:
    @user.user_images.build if @user.user_images.blank?
  end

  # GET/POST /me/bank_account
  def bank_account
    if request.post?
      #@user = current_user
      if @user_payment_account.update(user_payment_account_params)
        redirect_to payment_users_path( anchor: 'kontonummer' ), payment_account_notice: 'Kontonummeret ble godkjent og lagt til.'
      else
        render 'edit_user_payment_account', payment_account_notice: 'Kontonummeret bli ikke lagret.'
      end
    else
      render 'edit_user_payment_account'
    end
  end

  # PATCH/PUT /users/1
  def update

    if @user.update(user_params)
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

  # GET/PATCH /me/finish_signup
  def finish_signup
    if request.patch? && params[:user]
      if @user.update(user_params) && @user.basically_complete? && @user.valid?
        redirect_to private_profile_users_path
      else
        @show_errors = true
      end
    end
  end

  def finish_signup!
    unless current_user.basically_complete?
      redirect_to finish_signup_users_path
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
      redirect_to edit_users_path, sms_notice: 'Det ble nydelig sendt en SMS. Prøv igjen om litt.'
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
    @user_payment_cards = current_user.user_payment_cards.sort.map(&:decorate)
    @financial_transactions = FinancialTransaction.to_user( current_user.id ).transfer.finished.where('updated_at > ?', 1.year.ago).includes(:financial_transactionable)
  end

  # GET/POST /me/payment/payout
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
    # comment out the where clause to test, if you don't have archived ads
    @bookings = Booking.has_user(current_user).where(status: Booking.statuses[:archived]).decorate
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
  # NOTE/FIXME: birthday should only be allowed if the user verification_level is 0/not_verified.
  def user_params
    params.require(:user).permit(
      :about,
      :birthday,
      :country_of_residence,
      :current_phone_number,
      :email,
      :public_name,
      :home_address_line,
      :home_post_code,
      :last_name,
      :nationality,
      :password,
      :password_confirmation,
      :personhood,
      #:phone_number,
      :phone_number_confirmation_token,
      :public_name,
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