class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy]
  before_action :set_cardreg_redis_key, only: [:new]
  before_action :authenticate_user!

  # check that the user is provisioned in mangopay:
  #before_action :authenticate_user!


  # GET /user_payment_cards
  # GET /user_payment_cards.json
  def index
    @user_payment_cards = UserPaymentCard.where(user: current_user)
  end


  # GET /user_payment_cards/new
  def new
    # require service?

    # First look for a card cached in REDIS: (to save API calls)
    if not @user_payment_card = REDIS.get( @cardreg_redis_key )

      logger.info 'Creating a new Card Pre-registration with MangoPay, as no previous preregistrations could be found'
      pre_registered_card = MangopayService.new( current_user ).pre_register_card

      if not pre_registered_card.nil?
        logger.info "Pre-registration worked: #{pre_registered_card}"
        # Caching result serialized as json in REDIS:
        REDIS.setex( @cardreg_redis_key, MANGOPAY_PRE_REGISTERED_CARD_TTL, pre_registered_card.to_json )
      else
        logger.error "ERROR Pre-registrating the card. THIS IS NOT GOOD! Things will fail... => #{pre_registered_card}"
      end
    else
      # fetch from cache worked. deserialize it here.
      @user_payment_card = JSON.parse( @user_payment_card, object_class: OpenStruct )
    end
  end


  # POST /user_payment_cards
  # POST /user_payment_cards.json
  def create
    @user_payment_card = UserPaymentCard.new(user_payment_card_params)

    # once a card registration worked, drop it from cache.
    REDIS.del( @cardreg_redis_key )

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
    @user_payment_card.disable
    #invoke delayed job to set card to inactive in mangopay.

    redirect_to user_payment_cards_url, notice: 'UserPaymentCard was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_payment_card
      @user_payment_card = UserPaymentCard.find_by(guid: params[:guid], user_id: current_user.id)
    end

    def user_payment_card_params
      # these our internal only: :user_id, :card_registration_url, :number_alias, :expiration_date, :last_known_status_mp, :validity_mp, :active_mp,
      #     :access_key, :preregistration_data, :currency, :card_vid, :card_type,

      #{"Id":"8643628","Tag":null,"CreationDate":1443053319,"UserId":"8479933",
      # "AccessKey":"1X0m87dmM2LiwFgxPLBJ","PreregistrationData":"fztL6okJyT8dJpVcSz7IN5Sv5S5dDIa7HO2INEku8TQL-ts5Hd-r5bISeHOdqsfE7qGR3aNxrLUiPbx-Z--VxQ",
      # "RegistrationData":"data=VLTIjgpf1ag15dmwRyhmOYg3hZ6L5DgBcdo3GOE2TTbYfaHZtwSHj7s-9y2JRgs5e9QmqW0HYkgO-SOAebsYkCCoLBRBAVcOUSiYTNcoB_xYNk5b-x1WLCIFGB1NVbZf0ftIYwFxOdfmDQ5GtM_cIg",
      # "CardId":"8643681","CardType":"CB_VISA_MASTERCARD","CardRegistrationURL":"https://homologation-webpayment.payline.com/webpayment/getToken",
      # "ResultCode":"000000","ResultMessage":"Success","Currency":"NOK","Status":"VALIDATED"}

      # we probably dont care about: "Id", "UserId":"8479933", "CardType",
      # we care about: "CardId","Currency","Status","ResultCode","ResultMessage"
      params.require(:user_payment_card).permit(:guid, :card_id, :currency, :status)
    end

    def set_cardreg_redis_key
      @cardreg_redis_key = "mangopay-cardreg-preauth_uid:#{current_user.id}"
    end
end

