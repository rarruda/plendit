class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy, :make_favorite]
  before_action :authenticate_user!

  before_action :authorized?

  add_flash_types :payment_card_notice


  # GET /me/cards
  def index
    redirect_to payment_users_path
  end

  # GET /me/cards/new
  def new
    begin
      @user_payment_card = current_user.user_payment_cards.new().pre_register
    rescue => e
      LOG.error "ERROR Pre-registrating the card with mangopay. Not possible to render this page... #{e} => #{@user_payment_card}", { user_id: current_user.id }
      redirect_to payment_users_path, payment_card_notice: 'UserPaymentCard pre-registration failed. Cannot register a new card. Please try again later.'
    end
  end


  # POST /me/cards
  def create
    LOG.info "user_payment_card_params: #{user_payment_card_params}", {user_id: current_user.id}

    @user_payment_card = current_user.user_payment_cards.new(
      card_vid: user_payment_card_params['card_vid']
    )


    # as a background job:
    #@user_payment_card.process!


    if @user_payment_card.save
      redirect_to payment_users_path, payment_card_notice: 'Ditt betalingskort ble lagt til. Vi venter på godkjenning fra banken.'
    else
      LOG.error "Failed the saving the credit card.", {user_id: current_user.id, card_reg_vid: user_payment_card_params['card_reg_vid'] }
      redirect_to payment_users_path, payment_card_notice: 'UserPaymentCard was NOT successfully saved.'
    end
  end

  # POST /me/cards/make_favorite/1
  def make_favorite
    @user_payment_card.set_favorite

    redirect_to payment_users_path
  end


  # DELETE /me/cards/1
  def destroy
    @user_payment_card.disable
    redirect_to payment_users_path, payment_card_notice: 'UserPaymentCard was successfully destroyed.'
  end

  private
  def authorized?
    # only authorized to use this controller are users provisioned with mangopay:
    unless current_user.mangopay_provisioned?
      redirect_to payment_users_path, payment_card_notice: "You cant register cards yet. Your profile needs to be more complete."
      false
    end
  end

  def set_user_payment_card
    @user_payment_card = UserPaymentCard.find_by(guid: params[:guid], user_id: current_user.id)
  end

  def user_payment_card_params
    params.require(:user_payment_card).permit(:guid, :card_vid, :registration_data)
  end
end

