class UserPaymentCardsController < ApplicationController
  before_action :set_user_payment_card, only: [:destroy]
  before_action :set_cardreg_redis_key, only: [:new, :create, :flush_cache]
  before_action :set_mangopay_client, only: [:index, :new, :create, :destroy]
  before_action :authenticate_user!

  # check that the user is provisioned in mangopay:
  #before_action :authenticate_user!


  # GET /user_payment_cards
  # GET /user_payment_cards.json
  def index
    @user_payment_cards = UserPaymentCard.where(user: current_user)
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

      LOG.info 'Creating a new Card Pre-registration with MangoPay, as no previous preregistrations could be found', {user_id: current_user.id}
      @user_payment_card = @mangopay.card_pre_register

      if not @user_payment_card.nil?
        LOG.info "Pre-registration worked: #{@user_payment_card}"
        # Caching result serialized as json in REDIS:
        REDIS.setex( @cardreg_redis_key, MANGOPAY_PRE_REGISTERED_CARD_TTL, @user_payment_card.to_json )
      else
        LOG.error "ERROR Pre-registrating the card. THIS IS NOT GOOD! Things will fail... => #{@user_payment_card}", {user_id: current_user.id}
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
    mp_result = @mangopay.card_post_register( user_payment_card_params['card_vid'], user_payment_card_params['registration_data'] )
    LOG.info "mp: #{mp_result}", {user_id: current_user.id}

    if mp_result.status != 200
      #{"Message":"the card registration has already been processed","Type":"cardregistration_already_process","Id":"f5facd58-4b88-4618-ad21-d2c95bfce8e4#1443217025","Date":1443217026.0,"errors":null}
      LOG.error "Failed the final stage of registering the credit card. This is SUPER SAD!", {user_id: current_user.id}
      redirect_to user_payment_card_path, notice: 'UserPaymentCard failed registration.'
    else
      # registration went well.
      # clear cache:
      REDIS.del( @cardreg_redis_key )

      # get card details:
      card_info = @mangopay.get_card( user_payment_card_params['card_vid'] )
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
    #@mangopay.card_disable
    #invoke delayed job to set card to inactive in mangopay.

    redirect_to user_payment_cards_path, notice: 'UserPaymentCard was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_payment_card
      @user_payment_card = UserPaymentCard.find_by(guid: params[:guid], user_id: current_user.id)
    end

    def user_payment_card_params
      params.require(:user_payment_card).permit(:guid, :card_vid, :registration_data)
    end

    def set_mangopay_client
      @mangopay = MangopayService.new( current_user )
    end

    def set_cardreg_redis_key
      @cardreg_redis_key = "mangopay-cardreg-preauth_uid:#{current_user.id}"
    end
end

