class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy, :make_favorite]
  before_action :set_mangopay_client, only: [:index, :new, :create, :destroy]
  before_action :authenticate_user!

  before_action :authorized?

# user_payment_cards_path => payment_users_path

  # GET /me/cards
  def index
    #@user_payment_cards = UserPaymentCard.where(user: current_user)
    redirect_to user_payment_cards_path
  end

  # GET /me/cards/new
  def new
    LOG.info 'Creating a new Card Pre-registration with MangoPay', {user_id: current_user.id}
    @user_payment_card = @mangopay.card_pre_register

    if not @user_payment_card.nil?
      LOG.info "Pre-registration worked: #{@user_payment_card}"
    else
      LOG.error "ERROR Pre-registrating the card. THIS IS NOT GOOD! Things will fail... => #{@user_payment_card}", {user_id: current_user.id}
      redirect_to user_payment_cards_path, notice: 'UserPaymentCard pre-registration failed. Cannot register a new card. Please try again later.'
    end
  end


  # POST /me/cards
  def create
    LOG.info "user_payment_card_params: #{user_payment_card_params}"

    if @mangopay.card_post_register( user_payment_card_params['card_vid'], user_payment_card_params['registration_data'] )

      # card registration went well. now get the details: (should happen in model actually:)
      card_info = @mangopay.get_card( user_payment_card_params['card_vid'] )

      LOG.info "card_info: #{card_info}"
      # build card details in database:
      #@user_payment_card = UserPaymentCard.new( card_vid: user_payment_card_params['card_vid'], card_info )

      if @user_payment_card.save
        redirect_to user_payment_cards_path, notice: 'UserPaymentCard was successfully created.'
      else
        redirect_to user_payment_cards_path, notice: 'UserPaymentCard was NOT successfully saved.'
      end

    else
      LOG.error "Failed the final stage of registering the credit card.", {user_id: current_user.id}
      redirect_to user_payment_cards_path, notice: 'UserPaymentCard failed registration.'
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
    redirect_to user_payment_cards_path, notice: 'UserPaymentCard was successfully destroyed.'
  end

  private
  def authorized?
    # only authorized to use this controller are users provisioned with mangopay:
    unless current_user.mangopay_provisioned?
      redirect_to payment_users_path, notice: "You cant register cards right now" # you are not yet provisioned with mangopay
      false
    end
  end

  def set_user_payment_card
    @user_payment_card = UserPaymentCard.find_by(guid: params[:guid], user_id: current_user.id)
  end

  def user_payment_card_params
    params.require(:user_payment_card).permit(:guid, :card_vid, :registration_data)
  end

  def set_mangopay_client
    @mangopay = MangopayService.new( current_user )
  end
end

