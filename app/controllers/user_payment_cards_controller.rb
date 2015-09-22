class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy]
  before_filter :authenticate_user!

  # GET /user_payment_cards
  # GET /user_payment_cards.json
  def index
    @user_payment_cards = UserPaymentCard.all.decorate
  end


  # GET /user_payment_cards/new
  def new
    # require service?
    #
    # Find first if we have a stub in place, if so, try using it: (to save API calls)
    if not @user_payment_card = UserPaymentCard.find_by(user_id: current_user.id, last_known_status_mp: 'CREATED') #AND NOT CREATED MORE THEN 30 min ago?
      logger.info 'Creating a new Card Pre-registration with MangoPay, as no previous preregistrations could be found'
      pre_registered_card = MangopayService.new( current_user ).pre_register_card
      if not pre_registered_card.nil?
        logger.info "Pre-registration worked: #{pre_registered_card}"
        @user_payment_card = UserPaymentCard.new(pre_registered_card)
        @user_payment_card.save
      else
        logger.error "ERROR Pre-registrating the card. THIS IS NOT GOOD! => #{pre_registered_card}"
      end
    end
  end


  # POST /user_payment_cards
  # POST /user_payment_cards.json
  def create
    @user_payment_card = UserPaymentCard.new(user_payment_card_params)

    respond_to do |format|
      if @user_payment_card.save
        format.html { redirect_to @user_payment_card, notice: 'UserPaymentCard was successfully created.' }
        format.json { render :show, status: :created, location: @user_payment_card }
      else
        format.html { render :new }
        format.json { render json: @user_payment_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_payment_cards/1
  # DELETE /user_payment_cards/1.json
  def destroy
    @user_payment_card.active_mp = false
    @user_payment_card.save
    #invoke delayed job to set card to inactive in mangopay.

    redirect_to user_payment_cards_url, notice: 'UserPaymentCard was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_payment_card
      @user_payment_card = UserPaymentCard.find_by(guid: params[:guid])
    end

    def user_payment_card_params
      # these our internal only: :card_registration_url, :number_alias, :expiration_date, :last_known_status_mp, :validity_mp, :active_mp
      params.require(:user_payment_card).permit(:guid, :user_id, :card_vid, :currency, :card_type, :access_key, :preregistration_data, :registration_data)
    end
end

