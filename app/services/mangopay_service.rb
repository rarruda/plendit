require 'mangopay'

# This service should be used via a delayed job of some sort, for most operations.
class MangopayService


  def initialize(user)
    @user = user
  end

  # register a card:
  # see flow at: https://docs.mangopay.com/api-references/card-registration/
  def pre_register_card
    # It wont work if you dont have a registered user with the mangopay platform.
    return nil if @user.payment_provider_vid.nil?

    begin
      card_reg = MangoPay::CardRegistration.create(
        'UserId'   => @user.payment_provider_vid,
        'Currency' => "NOK",
        'CardType' => "CB_VISA_MASTERCARD"
      )
      pp card_reg
      card_info = {
        user_id:               @user.id,
        card_vid:              card_reg['Id'],
        access_key:            card_reg['AccessKey'],
        preregistration_data:  card_reg['PreregistrationData'],
        card_registration_url: card_reg['CardRegistrationURL'],
        last_known_status_mp:  card_reg['Status']
      }
      return card_info
    rescue => e
      puts e
      #logger.error e
      return nil
    end
  end


  # Disable an existing card. This is the equivalent of deleting it.
  # Note: It is an irreversible action.
  def disable_registered_card(params)
    begin
      MangoPay::Card.update(
        'Id'     => params.card_vid,
        'Active' => false
        )
    rescue => e
      puts e
      #logger.error e
      return nil
    end
  end


# NOTE: DUMMY CODE BELOW THIS LINE

    # you need to save the "Id" of the card in a new model
    #from result, (Save to db?) and show to user :
    #RegistrationData

  def post_register_card(params)
    MangoPay::CardRegistration.update(
      'RegistrationData' => 'NEW_REGISTRATION_DATA'
      )
    # now card is registered, and one can make a pre-authorization (pay w/o capture)
  end



  # CAPTURE A PAYMENT
  # this should be called once
  # https://docs.mangopay.com/api-references/payins/preauthorized-payin/
  def capture_payment
    # def charge_booking( booking )
    # maybe this is the capture step??
    MangoPay::PayIn::PreAuthorized.create?(
    'AuthorId'       => booking.from_user.id,
    'CreditedUserId' => booking.owner_user.id,
    'Type'           => 'PAY_IN',
    'ExecutionType'  => 'DIRECT',
    'DebitedFunds'   => booking.amount,
    'Fees'           => booking.fees?,             #<===== to be implemented
    'CreditedWalletId' => booking.owner_user.user_payment_account.payin_wallet_vid,
    'PreauthorizationId' => "foobar",              ###### foobar??? where does it come from?
    'Tag'            => "booking_id=#{booking.id}"
    )
  end


  # to preregister a payment: (create a payment, but not make a capture)
  def create_payment_preauth
    MangoPay::PreAuthorization.create(
      'CardId'       => booking.from_user.cards.pickone._id, # ????
      'DebitedFunds' => booking.amount,
      'AuthorId'     => booking.from_user.id,
      'SecureMode'   => 'DEFAULT',
      'SecureModeReturnURL' => 'url,',
      'Tag' => "booking_id=#{booking.id}"
    );
  end

#  Wait for "PreAuthorization" object to:
#      "Status": "SUCCEEDED",
#      "PaymentStatus" : " WAITING",


  # this should be called once the owner of the item confirms
  #  that he is willing to rent out in that time frame.
  # def capture_booking( booking )
  # end

  def user_provisionable?
    false if @user.id.nil? ||
      @user.personhood.nil? ||
      @user.first_name.nil? ||
      @user.last_name.nil? ||
      @user.email.nil? ||
      @user.birthday.nil? ||
      @user.country_of_residence.nil? ||
      @user.nationality.nil?
  end

  ## FIRST CHECK IF THE USER_ACCOUNT HAS ALL THE relevant information.
  ## see method above.
  # def provision_user_account( user )
    def provision_user
      # START OF USER_ACCOUNT_CREATION
      begin
        if @user.natural?
          mangopay_user = MangoPay::NaturalUser.create(
            'PersonType'  => @user.personhood,
            'FirstName'   => @user.first_name,
            'LastName'    => @user.last_name,
            'Email'       => @user.email,
            'Birthday'    => @user.birthday.strftime('%s').to_i,
            'Nationality' => @user.nationality,
            'CountryOfResidence' => @user.country_of_residence,
            'Tag'         => "id=#{@user.id}"
            #Optional:
            #'Address' => {
            #  'AddressLine1' =>
            #  'City'         =>
            #  'PostalCode'   =>
            #  'Country'      =>
            # }
            );
            logger.info "MangopayService.provision_user mangopay_user: #{mangopay_user}"
        else
          #NOT A NATURAL PERSON....
          # NOT TESTED
          mangopay_user = MangoPay::LegalUser.create(
            'PersonType'  => @user.personhood,
            'FirstName'   => @user.first_name,
            'LastName'    => @user.last_name,
            'Email'       => @user.email,
            #'Birthday'    => @user.birthday.strftime('%s'),
            #'Nationality' => @user.nationality,
            'CountryOfResidence' => @user.country_of_residence,
            'Tag'         => "id=#{@user.id}"
            #Optional:
            #'Address.AddressLine1' =>
            #'Address.City'         =>
            #'Address.PostalCode'   =>
            #'Address.Country'      =>
            );
        end
        @user.payment_provider_vid = mangopay_user['Id']
        @user.save!
        # END OF USER_ACCOUNT_CREATION
      rescue => e
        puts e
        #logger.error e
      end
    end

    def provision_wallets(user)
      begin
        wallet_in = MangoPay::Wallet.create(
            'Owners'      => @user.id,
            'Currency'    => PLENDIT_CURRENCY_CODE,
            'Description' => 'money_in',
            'Tag'         => 'pay_in'
          );
      rescue => e
        puts e
        #logger.error e
      end

      begin
        wallet_out = MangoPay::Wallet.create(
            'Owners'      => @user.id,
            'Currency'    => PLENDIT_CURRENCY_CODE,
            'Description' => 'money_out',
            'Tag'         => 'pay_out'
          );
      rescue => e
        puts e
        #logger.error e
      end
    end

    def provision_bank_accounts
      begin
        raise 'No addresses connected to this user.' if user.locations.length == 0

        MangoPay::BankAccount.create( @user.id, {
          'OwnerName'    => @user.name,
          'UserId'       => @user.id,
          'OwnerAddress' => "1 rue des Miserables(foo bar__test-value), #{@user.country_of_residence}",
          'IBAN'         => @user.user_payment_account.bank_account_iban
        } )
        #self.payment_provider_id = #...
      rescue => e
        puts e
        #logger.error e
      end
   end


  #### By default, you can’t create a payin over EUR 2500
  #### It is imperative to inform your users if you are registering their cards.

  ### ALL FAILURES should be written to LOG+DB

  ### ALL DB ENTRIES SHOULD HAVE A "TAKEN CARE OF IT FLAG"
end