class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy]
  before_action :set_cardreg_redis_key, only: [:new, :create, :flush_cache]
  before_action :authenticate_user!

  # check that the user is provisioned in mangopay:
  #before_action :authenticate_user!


  # GET /user_payment_cards
  # GET /user_payment_cards.json
  def index
    @user_payment_cards = UserPaymentCard.where(user: current_user)
    # from API:
    mangopay_service = MangopayService.new(current_user)
    @user_payment_cards_api = UserPaymentCard.where(user: current_user)
  end

  def flush_cache
    LOG.info "flushing card cache for user_id:#{current_user.id}", {user_id: current_user.id}
    REDIS.del( @cardreg_redis_key )
  end

  # GET /user_payment_cards/new
  def new
    # require service?

    # First look for a card cached in REDIS: (to save API calls)
    if not @user_payment_card = REDIS.get( @cardreg_redis_key )

      LOG.info 'Creating a new Card Pre-registration with MangoPay, as no previous preregistrations could be found'
      @user_payment_card = MangopayService.new( current_user ).pre_register_card

      if not @user_payment_card.nil?
        LOG.info "Pre-registration worked: #{@user_payment_card}"
        # Caching result serialized as json in REDIS:
        REDIS.setex( @cardreg_redis_key, MANGOPAY_PRE_REGISTERED_CARD_TTL, @user_payment_card.to_json )
      else
        LOG.error "ERROR Pre-registrating the card. THIS IS NOT GOOD! Things will fail... => #{@user_payment_card}"
        redirect_to user_payment_cards_path, notice: 'UserPaymentCard pre-registration failed. Cannot register a new card.'
      end
    else
      # fetch from cache worked. deserialize it here.
      @user_payment_card = JSON.parse( @user_payment_card ).symbolize_keys
    end
  end


  # POST /user_payment_cards
  # POST /user_payment_cards.json
  def create
    puts "user_payment_card_params: #{user_payment_card_params}"

    # finish card registration:
    mangopay_service = MangopayService.new( current_user )
    mp_result = mangopay_service.post_register_card( user_payment_card_params['card_vid'], user_payment_card_params['registration_data'] )
    LOG.info "mp: #{mp_result}"

    if mp_result.status != 200
      #{"Message":"the card registration has already been processed","Type":"cardregistration_already_process","Id":"f5facd58-4b88-4618-ad21-d2c95bfce8e4#1443217025","Date":1443217026.0,"errors":null}
      LOG.error "Failed the final stage of registering the credit card. This is SUPER SAD!"
      redirect_to user_payment_card_path, notice: 'UserPaymentCard failed registration.'
    else
      # registration went well.
      # clear cache:
      REDIS.del( @cardreg_redis_key )

      # get card details:
      card_info = mangopay_service.get_card( user_payment_card_params['card_vid'] )
    end

    puts "card_info: #{card_info}"
    # build card details in database:
    # @user_payment_card = UserPaymentCard.new( card_vid: user_payment_card_params['card_vid'], card_info )


    if @user_payment_card.save
      redirect_to user_payment_card_path, notice: 'UserPaymentCard was successfully created.'
    else
      redirect_to user_payment_cards_path, notice: 'UserPaymentCard was successfully destroyed.'
    end
  end

  # DELETE /user_payment_cards/1
  # DELETE /user_payment_cards/1.json
  def destroy
    @user_payment_card.disable
    #invoke delayed job to set card to inactive in mangopay.

    redirect_to user_payment_cards_path, notice: 'UserPaymentCard was successfully destroyed.'
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
      params.require(:user_payment_card).permit(:guid, :card_vid, :registration_data)
    end

    def set_cardreg_redis_key
      @cardreg_redis_key = "mangopay-cardreg-preauth_uid:#{current_user.id}"
    end
end

