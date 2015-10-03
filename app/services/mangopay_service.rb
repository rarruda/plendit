require 'mangopay'

# This service should be used via a delayed job of some sort, for most operations.
class MangopayService


  MANGOPAY_CURRENCY='NOK'

  def initialize(user)
    @user = user
  end

  # register a card:
  # see flow at: https://docs.mangopay.com/api-references/card-registration/
  def card_pre_register
    # It wont work if you dont have a registered user with the mangopay platform.
    raise 'payment_provider_vid is nil. Can not create a pre_registration for a card.' if @user.payment_provider_vid.nil?

    begin
      card_reg = MangoPay::CardRegistration.create(
        'Tag'      => "user_id=#{@user.id}",
        'UserId'   => @user.payment_provider_vid,
        'Currency' => MANGOPAY_CURRENCY,
        'CardType' => "CB_VISA_MASTERCARD"
      )

      card_info = {
        user_id:               @user.id,
        card_vid:              card_reg['Id'],
        access_key:            card_reg['AccessKey'],
        preregistration_data:  card_reg['PreregistrationData'],
        card_registration_url: card_reg['CardRegistrationURL'],
        last_known_status_mp:  card_reg['Status']
      }
    rescue => e
      LOG.error e, { user_id: @user.id }
      return nil
    end
    LOG.info card_reg, { user_id: @user.id }
    LOG.info card_info, { user_id: @user.id }
    return card_info
  end


  # Disable an existing card. This is the equivalent of deleting it.
  # Note: It is an irreversible action.
  def card_disable(card_vid)
    begin
      c = MangoPay::Card.update(
        'Id'     => card_vid,
        'Active' => false
        )
    rescue => e
      LOG.error "error disabling card_vid:#{card_vid} => #{c}", { user_id: @user.id, card_vid: card_vid }
      LOG.error e
      return nil
    end
    LOG.info "disabled card_vid:#{card_vid} => #{c}",{ user_id: @user.id, card_vid: card_vid }
  end


  # you need to save the "Id" of the card in a new model
  #from result, (Save to db?) and show to user :
  #RegistrationData
  def card_post_register(card_vid, registration_data)
    begin
      card = MangoPay::CardRegistration.update( card_vid, {'RegistrationData' => registration_data} )
      # now card is registered, and one can make a pre-authorization (pay w/o capture)
      @user.user_payment_card.card_vid  = card['CardId']
      @user.user_payment_card.status_mp = card['Status']
      @user.user_payment_card.save!
    rescue MangoPay::ResponseError => e
      LOG.error "error registering card with mangopay. MangoPay::ResponseError: #{e}", { user_id: @user.id, card_vid: card_vid, mangopay_result: card }
    rescue => e
      LOG.error "error registering card. exception: #{e}", { user_id: @user.id, card_vid: card_vid, mangopay_result: card }
    end
  end

  def card_list
    begin
      cards = MangoPay::User.cards( @user.payment_provider_vid )
    #rescue MangoPay::ResponseError => e
    #  LOG.error "error fetching list of cards with mangopay. MangoPay::ResponseError: #{e}", { user_id: @user.id, mangopay_result: cards }
    rescue => e
      LOG.error "error fetching list of cards with mangopay. exception: #{e}", { user_id: @user.id, mangopay_result: cards }
    end
    cards
  end

  def user_provisionable?
    return false if @user.id.blank? ||
      @user.personhood.blank? ||
      @user.first_name.blank? ||
      @user.last_name.blank? ||
      @user.email.blank? ||
      @user.birthday.blank? ||
      @user.country_of_residence.blank? ||
      @user.nationality.blank?

    true
  end

  def provision_user
    if @user.personhood.blank?
      LOG.error "Refuse to provision user. Don't know the personhood of user. bailing out.", { user_id: @user.id, personhood: @user.personhood }
      return false
    end

    if not self.user_provisionable?
      LOG.error "Refuse to provision user. The profile is NOT complete. bailing out.", { user_id: @user.id }
      return false
    else
      LOG.info "profile IS complete", { user_id: @user.id }
    end

    # START OF USER_ACCOUNT_CREATION
    begin
      if @user.natural?
        mangopay_user = MangoPay::NaturalUser.create(
          'Tag'         => "user_id=#{@user.id}",
          'PersonType'  => @user.personhood,
          'FirstName'   => @user.first_name,
          'LastName'    => @user.last_name,
          'Email'       => @user.email,
          'Birthday'    => @user.birthday.strftime('%s').to_i,
          'Nationality' => @user.nationality,
          'CountryOfResidence' => @user.country_of_residence,
        );
          #Optional:
          #'Address' => {
          #  'AddressLine1' => @user.home_address_line,
          #  'City'         => @user.home_city,
          #  'PostalCode'   => @user.home_post_code,
          #  'Country'      => @user.country_of_residence
          # }
        @user.payment_provider_vid = mangopay_user['Id']
        @user.save!
      else
        #NOT A NATURAL PERSON.... // code is NOT TESTED!!
        legal_person_type = case @user.personhood
        when :legal_business
          'BUSINESS'
        when :legal_organization
          'ORGANIZATION'
        else
          LOG.error "Refuse to provision user. User has invalid legal_person_type/personhood: #{@user.personhood}", { user_id: @user.id, personhood: @user.personhood }
          raise 'trying to provision a user that does not match a valid value'
        end

        #https://docs.mangopay.com/api-references/users/legal-users/
        mangopay_user = MangoPay::LegalUser.create(
          'Tag'         => "user_id=#{@user.id}",
          'Name'        => @user.name,  #company name
          'Email'       => @user.email, #company email
          'LegalPersonType'                => legal_person_type,
          'LegalRepresentativeFirstName'   => @user.first_name,
          'LegalRepresentativeLastName'    => @user.last_name,
          'LegalRepresentativeBirthday'    => @user.birthday.strftime('%s'),
          'LegalRepresentativeNationality' => @user.nationality,
          'LegalRepresentativeCountryOfResidence' => @user.country_of_residence
        );
          #Optional:
          # 'LegalRepresentativeEmail' =>
          # 'HeadquartersAddress' =>
          # 'LegalRepresentativeAddress' => {
          #    'AddressLine1' =>
          #    'City'         =>
          #    'PostalCode'   =>
          #    'Country'      =>
          # }
      end
      @user.payment_provider_vid = mangopay_user['Id']
      @user.save!
    rescue => e
      LOG.error "something has gone wrong with provisioning the user at mangopay. exception: #{e}", {user_id: @user.id, mangopay_result: mangopay_user }
    end
    LOG.info "MangopayService.provision_user #{@user.personhood} mangopay_user: #{mangopay_user}", {user_id: @user.id}
  end

  def provision_payin_wallet
    begin
      wallet_in = MangoPay::Wallet.create(
          'Tag'         => "pay_in user_id=#{@user.id}",
          'Owners'      => [ @user.payment_provider_vid ],
          'Currency'    => PLENDIT_CURRENCY_CODE,
          'Description' => 'money_in',
        );
      @user.payin_wallet_vid = wallet_in['Id']
      @user.user_payment_account.save!
    rescue => e
      LOG.error "something has gone wrong with provisioning the pay_in wallet at mangopay. exception: #{e}", {user_id: @user.id, mangopay_result: wallet_in }
    end
    LOG.info "created pay_in wallet:#{wallet_in}", { user_id: @user.id, mangopay_result: wallet_in }
  end

  def provision_payout_wallet
    begin
      wallet_out = MangoPay::Wallet.create(
          'Tag'         => "pay_out user_id=#{@user.id}",
          'Owners'      => [ @user.payment_provider_vid ],
          'Currency'    => PLENDIT_CURRENCY_CODE,
          'Description' => 'money_out'
        );
      @user.payout_wallet_vid = wallet_out['Id']
      @user.user_payment_account.save!
    rescue => e
      LOG.error "something has gone wrong with provisioning the pay_out wallet at mangopay. exception: #{e}", {user_id: @user.id, mangopay_result: wallet_out }
    end
    LOG.info "created pay_out wallet:#{wallet_out}", { user_id: @user.id, mangopay_result: wallet_out }
  end

  def provision_bank_account
    # check if user has all necessary information.
    if not ( @user.has_address? && @user.mangopay_provisioned? )
      LOG.error 'No addresses connected to this user. Refuse to provision bank account.', { user_id: @user.id }
      #raise 'No addresses connected to this user.'
      return false
    end

    begin
      bank_account = MangoPay::BankAccount.create( @user.payment_provider_vid, {
        'Tag'          => "user_id=#{@user.id}",
        'OwnerName'    => @user.name,
        'Type'         => 'IBAN',
        'UserId'       => @user.payment_provider_vid,
        'IBAN'         => @user.user_payment_account.bank_account_iban,
        'OwnerAddress' => {
          'AddressLine1' => @user.home_address_line,
          'City'         => @user.home_city,
          'PostalCode'   => @user.home_post_code,
          'Country'      => @user.country_of_residence
        }
      } );
      @user.user_payment_account.bank_account_vid = bank_account['Id']
      @user.user_payment_account.save!
    rescue => e
      LOG.error e
      LOG.error 'something has gone wrong with provisioning the bank_account at mangopay.', {user_id: @user.id, mangopay_result: bank_account }
    end
    LOG.info "created bank_account:#{bank_account['Id']}", { user_id: @user.id, bank_account_vid: bank_account['Id'], mangopay_result: bank_account }

  end




### NOTE: DUMMY CODE BELOW THIS LINE




  # CAPTURE A PAYMENT
  # this should be called once
  # https://docs.mangopay.com/api-references/payins/preauthorized-payin/
  def payment_capture
    # def charge_booking( booking )
    # maybe this is the capture step??
    result = MangoPay::PayIn::PreAuthorized.create?(
      'Tag'            => "booking_id=#{booking.id}",
      'AuthorId'       => booking.from_user.id,
      'CreditedUserId' => booking.owner_user.id,
      'Type'           => 'PAY_IN',
      'ExecutionType'  => 'DIRECT',
      'DebitedFunds'   => booking.amount,
      'Fees'           => booking.fees?,             #<===== to be implemented
      'CreditedWalletId'   => booking.owner_user.payin_wallet_vid,
      'PreauthorizationId' => "foobar",              ###### foobar??? where does it come from?
    );
  end


  # to preregister a payment: (create a payment, but not make a capture)
  def payment_preauth_create #(to_user, amount)
    result = MangoPay::PreAuthorization.create(
      'Tag'          => "booking_id=#{booking.id}", #from_user_id= to_user_id
      'CardId'       => booking.from_user.cards.pickone._id, # ????
      'DebitedFunds' => booking.amount,
      'AuthorId'     => booking.from_user.id,
      'SecureMode'   => 'DEFAULT',
      'SecureModeReturnURL' => 'url,',
    );
  end


#  Wait for "PreAuthorization" object to:
#      "Status": "SUCCEEDED",
#      "PaymentStatus" : " WAITING",


  # this should be called once the owner of the item confirms
  #  that he is willing to rent out in that time frame.
  # def capture_booking( booking )
  # end






  #### By default, you can’t create a payin over EUR 2500
  #### It is imperative to inform your users if you are registering their cards.
  ### ALL FAILURES should be written to LOG+DB
end