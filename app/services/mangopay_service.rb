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


  # you need to save the "Id" of the card in a new model
  #from result, (Save to db?) and show to user :
  #RegistrationData
  def card_post_register(card_vid, registration_data)
    begin
      # https://docs.mangopay.com/api-references/card-registration/
      card = MangoPay::CardRegistration.update( card_vid, { 'RegistrationData' => registration_data } )
      # now card is registered, and one can make a pre-authorization (pay w/o capture)
      @user.user_payment_cards.build(
          card_vid:  card['CardId'],
          status_mp: card['Status']
        )
      @user.user_payment_card.save!
    rescue MangoPay::ResponseError => e
      LOG.error "error registering card with mangopay. MangoPay::ResponseError: #{e}", { user_id: @user.id, card_vid: card_vid, mangopay_result: card }
      false
    rescue => e
      LOG.error "error registering card. exception: #{e}", { user_id: @user.id, card_vid: card_vid, mangopay_result: card }
      false
    end
  end



  # Disable an existing card. This is the equivalent of deleting it.
  # Note: It is an irreversible action.
  def card_disable(card_vid)
    begin
      # https://docs.mangopay.com/api-references/card/
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




  def card_list
    begin
      cards = MangoPay::User.cards( @user.payment_provider_vid )
    rescue => e
      LOG.error "error fetching list of cards with mangopay. exception: #{e}", { user_id: @user.id, mangopay_result: cards }
    end
    cards
  end

  def card_list_refresh
    begin
      cards = MangoPay::User.cards( @user.payment_provider_vid )
      cards.each do |c|
        card = @user.user_payment_cards.find_by(card_vid: c['Id'])
        # if the card does not exist from before.
        if card.blank?
          @user.user_payment_cards.new(
            card_vid:  c['Id'],
            card_type: c['CardType'],
            card_provider: c['CardProvider'],
            currency:  c['Currency'],
            country:   c['Country'],
            number_alias: c['Alias'],
            expiration_date: c['ExpirationDate'],
            validity:  c['Validity'],
            active:    c['Active']
            );
          #@user.save!
          LOG.info "Created a new card.", { user_id: @user.id, card_vid: c['Id'] }
        else
          LOG.warn "Should be Updating card information... but no code here..", { user_id: @user.id, card_id: card.id, card_vid: c['Id'] }
          #card.update #with data from api.
        end
      end
      @user.save!
    rescue => e
      LOG.error "Exception e:#{e} error refreshing cards from mangopay.", { user_id: @user.id, mangopay_result: cards }
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
        # https://docs.mangopay.com/api-references/users/natural-users/
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
        #NOT A NATURAL PERSON.... // code is NOT TESTED!!11
        LOG.warn "NOT A NATURAL PERSON.... This code is NOT TESTED!!", { user_id: @user.id, personhood: @user.personhood }

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

  # this method is not throughly tested:
  def provision_wallets
    return true unless @user.payin_wallet_vid.blank? && @user.payout_wallet_vid.blank?

    begin
      wallets = MangoPay::User.wallets( @user.payment_provider_vid, {sort: 'CreationDate:asc'} )

      unless wallets.blank?
        wallet_money_in  = []
        wallet_money_out = []

        wallets.each do |w|
          wallet_money_in  << w['Id'] if w['Description'] == 'money_in'
          wallet_money_out << w['Id'] if w['Description'] == 'money_out'
        end

        @user.payin_wallet_vid  = wallet_money_in.first  if wallet_money_in.length  >= 1 && @user.payin_wallet_vid.blank?
        @user.payout_wallet_vid = wallet_money_out.first if wallet_money_out.length >= 1 && @user.payout_wallet_vid.blank?
        @user.save!
      end

      #pp wallets
    rescue => e
      LOG.error "something has gone wrong with fetching list of wallets at mangopay. exception: #{e}", {user_id: @user.id, mangopay_result: wallets }
    end

    LOG.info "found payin_wallets:#{wallet_money_in}, saved payin_wallet", { user_id: @user.id, mangopay_result: wallets }    if @user.payin_wallet_vid_changed?
    LOG.info "found payout_wallets:#{wallet_money_out}, saved payout_wallet", { user_id: @user.id, mangopay_result: wallets } if @user.payout_wallet_vid_changed?


    self.provision_payin_wallet  if @user.payin_wallet_vid.blank?
    self.provision_payout_wallet if @user.payin_wallet_vid.blank?
  end

  def provision_payin_wallet
    return @user.payin_wallet_vid unless @user.payin_wallet_vid.blank?

    begin
      # https://docs.mangopay.com/api-references/wallets/
      wallet_in = MangoPay::Wallet.create(
          'Tag'         => "pay_in user_id=#{@user.id}",
          'Owners'      => [ @user.payment_provider_vid ],
          'Currency'    => PLENDIT_CURRENCY_CODE,
          'Description' => 'money_in',
        );
      @user.payin_wallet_vid = wallet_in['Id']
      @user.save!
    rescue => e
      LOG.error "Exception e:#{e} something has gone wrong with provisioning the pay_in wallet at mangopay.", {user_id: @user.id, mangopay_result: wallet_in }
    end
    LOG.info "created pay_in wallet:#{wallet_in}", { user_id: @user.id, mangopay_result: wallet_in }
  end

  def provision_payout_wallet
    return @user.payout_wallet_vid unless @user.payout_wallet_vid.blank?

    begin
      # https://docs.mangopay.com/api-references/wallets/
      wallet_out = MangoPay::Wallet.create(
          'Tag'         => "pay_out user_id=#{@user.id}",
          'Owners'      => [ @user.payment_provider_vid ],
          'Currency'    => PLENDIT_CURRENCY_CODE,
          'Description' => 'money_out'
        );
      @user.payout_wallet_vid = wallet_out['Id']
      @user.save!
    rescue => e
      LOG.error "Exception e:#{e} something has gone wrong with provisioning the pay_out wallet at mangopay.", {user_id: @user.id, mangopay_result: wallet_out }
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
      # https://docs.mangopay.com/api-references/bank-accounts/
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
      LOG.error "Exception e:'#{e}' has gone wrong with provisioning the bank_account at mangopay.", {user_id: @user.id, mangopay_result: bank_account }
    end
    LOG.info "created bank_account:#{bank_account['Id']}", { user_id: @user.id, bank_account_vid: bank_account['Id'], mangopay_result: bank_account }

  end




### NOTE: DUMMY CODE BELOW THIS LINE


### UNIT TESTS are something i miss.


  # to preregister a payment: (create a preauthorization//create a payment, but not make a capture)
  def payment_preauth_create booking, card_id
    # check that the card belongs to the booking.from_user
    card = booking.from_user.user_payment_cards.find( card_id )
    return false if card.nil?

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb
      preauth = MangoPay::PreAuthorization.create(
        'Tag'          => "booking_id=#{booking.id}", #from_user_id= to_user_id
        'CardId'       => card.card_vid,
        'DebitedFunds' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => booking.sum_paid_by_renter
        },
        'AuthorId'     => booking.from_user.payment_provider_vid,
        'SecureMode'   => 'DEFAULT',
        'SecureModeReturnURL' => booking_url( booking.guid ),
      );

      # save in transaction from what mangopay reports to have done.
      #   not from what we think it should be done.
      transaction = {
        src_vid:    preauth['CardId'],
        src_type:   'src_card_vid',
        dst_vid:    nil, #booking.user.,
        dst_type:   nil, #'dst_payin_wallet_vid',
        booking_id: booking.id,
        amount:     preauth['DebitedFunds']['Amount'],
        category:   'payin_preauth',
        status_mp:  preauth['Status'].downcase, #could be an issue of type mismatch string/integer
        transaction_type: 'preauth',
        transaction_vid:  preauth['Id'],
        result_code:    preauth['ResultCode'],
        result_message: preauth['ResultMessage'],
        response_body:  preauth
      }
      t = Transaction.new( transaction )
      t.save!

      LOG.info "have created for user_id: #{booking.from_user.id} PreAuthorization: #{preauth}", { user_id: booking.from_user.id, mangopay_result: preauth }
    rescue => e
      LOG.error "Exception e:#{e} for user_id: #{booking.from_user.id} PreAuthorization: #{preauth}", { user_id: booking.from_user.id, mangopay_result: preauth }
    end

    if preauth['Status'] == 'FAILED'
      LOG.error "Error for user_id: #{booking.from_user.id} PreAuthorization: #{preauth}", { user_id: booking.from_user.id, mangopay_result: preauth }
      return false
    else
      return true
    end
  end


#  Wait for "PreAuthorization" object to:
#      "Status": "SUCCEEDED",
#      "PaymentStatus" : " WAITING",
  def payment_preauth_refresh
    # update transaction to reflect new status_mp
  end

  # OK!
  # this should be called once the owner of the item confirms
  #  that he is willing to rent out in that time frame.
  #
  def payment_payin_from_preauth booking
    # check that preauth has succeeded/exists:
    if booking.last_preauthorization_vid.blank?
      LOG.error "Cannot make a payin from preauth, as it was not possible to locate the payin for this booking", {user_id: user.id, booking_id: booking.id}
      return false
    end

    preauth_mp = MangoPay::PreAuthorization.fetch booking.last_preauthorization_vid
    if preauth_mp['Status'] == 'FAILED'
      LOG.error "Last PreAuthorization #{booking.last_preauthorization_vid} for booking_id:#{booking.id} is no longer valid.", { booking_id: booking.id }
    end

    begin
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_in.rb#L30
      # https://docs.mangopay.com/api-references/payins/preauthorized-payin/
      payin = MangoPay::PayIn::PreAuthorized::Direct.create(
        'Tag'                => "booking_id=#{booking.id}",
        'AuthorId'           => booking.from_user.payment_provider_vid,
        'CreditedUserId'     => booking.from_user.payment_provider_vid,
        'PreauthorizationId' => 'DIRECT',
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => booking.sum_paid_by_renter
          },
        'Fees'           => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => 0
          },
        'CreditedWalletId'    => booking.user.payin_wallet_vid,
        'PreauthorizationId'  => booking.last_preauthorization_vid,
        'SecureModeReturnURL' => booking_url( booking.guid )
      )

      transaction = {
        src_vid:    payin['PreauthorizationId'],
        src_type:   'src_preauth_vid',
        dst_vid:    payin['CreditedWalletId'], #booking.user.payin_wallet_vid,
        dst_type:   'dst_payin_wallet_vid',
        booking_id: booking.id,
        amount:     payin['DebitedFunds']['Amount'],
        category:   'payin_capture',          # payin_capture is not a great name.
        status_mp:  payin['Status'].downcase, #NB! There could be an issue of type mismatch string/integer(enum).
        transaction_type: 'payin',
        transaction_vid:  payin['Id'],
        result_code:    payin['ResultCode'],
        result_message: payin['ResultMessage'],
        response_body:  payin
      }
      # MISSING: result_code, result_message, result_body
      # create a transaction record.
      t = Transaction.new( transaction )
      t.save!

      LOG.info "Processed PayIn from PreAuthorization for booking_id:#{booking.id} transaction_id:#{t.id}", { booking_id: booking.id, mangopay_result: payin }
    rescue => e
      LOG.error "Exception e:#{e} processing PayIn from PreAuthorization for booking_id:#{booking.id} payin:#{payin}", { booking_id: booking.id, mangopay_result: payin }
    end

    if payin['Status'] == 'FAILED'
      return false
    else
      return true
    end
  end


  def payment_transfer booking
    begin
      # https://docs.mangopay.com/api-references/transfers/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/transfer.rb
      transfer = MangoPay::Transfer.create(
        'Tag'            => "booking_id=#{booking.id}",
        'AuthorId'       => booking.user.payment_provider_vid,
        'CreditedUserId' => booking.user.payment_provider_vid, # Note: CreditedUserId And AuthorId must always be the same value!
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => booking.sum_paid_by_renter #platform_fee_with_insurance is removed in Fees.
        },
        'Fees' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => booking.platform_fee_with_insurance
        },
        'DebitedWalletId'  => booking.from_user.payin_wallet_vid,
        'CreditedWalletId' => booking.user.payout_wallet_vid
        );
      transaction = {
        src_vid:    transfer['DebitedWalletId'],
        src_type:   'src_payin_wallet_vid',
        dst_vid:    transfer['CreditedWalletId'],
        dst_type:   'dst_payout_wallet_vid',
        booking_id: booking.id,
        #debited_amount: transfer['DebitedFunds']['Amount'],
        amount:     transfer['CreditedFunds']['Amount'],
        fee:        transfer['Fees']['Amount'],
        category:   'transfer_to_renter',
        status_mp:  transfer['Status'].downcase, #NB! There could be an issue of type mismatch string/integer(enum).
        transaction_type: 'transfer',
        transaction_vid:  transfer['Id'],
        result_code:    transfer['ResultCode'],
        result_message: transfer['ResultMessage'],
        response_body:  transfer
      }
      # MISSING: result_code, result_message, result_body
      # create a transaction record.
      t = Transaction.new( transaction )
      t.save!

      LOG.info "have created for user_id: #{@user.id} Transfer: #{transaction}", { user_id: @user.id, booking_id: booking.id, mangopay_result: transfer }
    rescue MangoPay::ResponseError => e
      LOG.error "Exception e:#{e} processing transfer for booking_id:#{booking.id}", { booking_id: booking.id, mangopay_result: transfer }
    rescue => e
      LOG.error "Exception e:#{e} processing transfer for booking_id:#{booking.id}", { booking_id: booking.id, mangopay_result: transfer }
    end

    if transfer['Status'] == 'FAILED'
      return false
    else
      return true
    end
  end

  # OK
  def payment_payout amount
    #check if there are enough funds....
    # find out how much can be withdrawn
    # FIXME: check if a payout fee will apply?

    # Payout_fee is 25 NOK for payouts less then 1000 NOK.
    #   its 0 (free) for payouts over 1000 NOK.
    payout_fee = ( amount >= 1_000_00 ) ? 0 : 25_00

    begin

      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payout = MangoPay::PayOut.create(
        'Tag'            => "user_id=#{booking.id}",
        'AuthorId'       => @user.payment_provider_vid,
        'CreditedUserId' => @user.payment_provider_vid, # Note: CreditedUserId And AuthorId must always be the same value!
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => 0
          },
        'Fees' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => payout_fee
          },
        'DebitedWalletId'  => @user.payout_wallet_vid,
        'BankAccountId'    => @user.user_payment_account.bank_account_vid,
        'BankWireRef'      => 'From plendit with love.'
      );

      transaction = {
        src_vid:    payout['DebitedWalletId'],
        src_type:   'src_payout_wallet_vid',
        dst_vid:    payout['CreditedWalletId'],
        dst_type:   'dst_bank_account_vid',
        booking_id: nil,
        #debited_amount: transfer['DebitedFunds']['Amount'],
        amount:     payout['CreditedFunds']['Amount'],
        fee:        payout['Fees']['Amount'],
        category:   'payout_to_bank_account',
        status_mp:  payout['Status'].downcase, #NB! There could be an issue of type mismatch string/integer(enum).
        transaction_type: 'payout',
        transaction_vid:  payout['Id'],
        result_code:    payout['ResultCode'],
        result_message: nil,                  # No ResultMessage for payouts
        response_body:  payout
      }
      # MISSING: result_code, result_message, result_body
      # create a transaction record.
      t = Transaction.new( transaction )
      t.save!

      LOG.info "have created for user_id: #{@user.id} PayOut: #{payout}", { user_id: @user.id, mangopay_result: payout }
    rescue => e
      LOG.error "Exception e:#{e} processing payout for user_id:#{@user.id}", { user_id: @user.id, mangopay_result: payout }
    end

    if payout['Status'] == 'FAILED'
      return false
    else
      return true
    end
  end


  #### By default, you can’t create a payin over EUR 2500
  #### It is imperative to inform your users if you are registering their cards.
  ### ALL FAILURES should be written to LOG+DB
end