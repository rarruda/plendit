require 'mangopay'

# This service should be used via a delayed job of some sort, for most operations.
class MangopayService

  def initialize(user)
    @user = user
  end



  # create a new user_payment_card instance from RegistrationData
  def card_post_register( card_preauth_vid, registration_data)
    begin
      # https://docs.mangopay.com/api-references/card-registration/
      LOG.info "performing card registration from RegistrationData"
      card = MangoPay::CardRegistration.update( card_preauth_vid, { 'RegistrationData' => registration_data } )
      LOG.info "Got the following card back: #{card}", { user_id: @user.id }

      # now card is registered, and one can make a pre-authorization (pay w/o capture)
      @user.user_payment_cards.create!( card_vid: card['CardId'] )

    rescue MangoPay::ResponseError => e
      LOG.error "error registering card with mangopay. MangoPay::ResponseError: #{e}", { user_id: @user.id, card_preauth_vid: card_preauth_vid, mangopay_result: card }
      return nil
    rescue => e
      LOG.error "error registering card. exception: #{e}", { user_id: @user.id, card_preauth_vid: card_preauth_vid, mangopay_result: card }
      return nil
    end
    return card['CardId']
  end





  def card_fetch( card_vid )
    begin
      mp_card = MangoPay::Cards.fetch( card_vid )
      card = mp_card_translate( mp_card )

    rescue => e
      LOG.error "error fetching card with mangopay. exception: #{e}", { user_id: @user.id, card_vid: card_vid, mangopay_result: card }
      return nil
    end
    card
  end

  def card_list( options = {refresh: false} )
    begin
      mp_cards = MangoPay::User.cards( @user.payment_provider_vid )
      mp_cards.each do |mp_card|
        local_card = @user.user_payment_cards.find_by(card_vid: mp_card['Id'])

        card = mp_card_translate( mp_card )

        if options[:refresh]
          # if the card does not exist from before.
          if local_card.blank?
            @user.user_payment_cards.create(card)
          else
            local_card.update(card)
          end
          @user.save!
        end

      end
    rescue => e
      LOG.error "error fetching list of cards with mangopay. exception: #{e}", { user_id: @user.id, mangopay_result: cards }
      return nil
    end
    # cards
    @user.user_payment_cards.all
  end

  def card_list_refresh
    self.card_list( refresh: true )
  end

  #private
  def mp_card_translate ( mp_card )
    return nil if mp_card.blank? || ! ( mp_card.is_a? Hash )

    {
      card_vid:        mp_card['Id'],
      card_type:       mp_card['CardType'],
      card_provider:   mp_card['CardProvider'],
      currency:        mp_card['Currency'],
      country:         mp_card['Country'],
      number_alias:    mp_card['Alias'],
      expiration_date: mp_card['ExpirationDate'],
      validity:        mp_card['Validity'],
      active:          mp_card['Active']
    }
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
    LOG.info "Provisioning user with Mangopay", { user_id: @user.id }

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
      return nil
    end
    LOG.info "MangopayService.provision_user #{@user.personhood} mangopay_user: #{mangopay_user}", {user_id: @user.id}
  end

  # this method is not throughly tested:
  def provision_wallets
    LOG.info "Provisioning wallets with Mangopay", { user_id: @user.id }

    return true if @user.payin_wallet_vid.present? && @user.payout_wallet_vid.present?

    begin
      wallets = MangoPay::User.wallets( @user.payment_provider_vid, {sort: 'CreationDate:asc'} )

      if wallets.present?
        wallet_money_in  = []
        wallet_money_out = []

        wallets.each do |w|
          wallet_money_in  << w['Id'] if w['Description'] == 'money_in'
          wallet_money_out << w['Id'] if w['Description'] == 'money_out'
        end

        @user.payin_wallet_vid  = wallet_money_in.first  if wallet_money_in.length  >= 1 && @user.payin_wallet_vid.blank?
        @user.payout_wallet_vid = wallet_money_out.first if wallet_money_out.length >= 1 && @user.payout_wallet_vid.blank?
      else
        LOG.info "not doing anything"
      end

      pp wallets
    rescue => e
      LOG.error "something has gone wrong with fetching list of wallets at mangopay. exception: #{e}", {user_id: @user.id, mangopay_result: wallets }
      return nil
    end

    LOG.info "found payin_wallets:#{wallet_money_in}, saved payin_wallet", { user_id: @user.id, mangopay_result: wallets }    if @user.payin_wallet_vid_changed?
    LOG.info "found payout_wallets:#{wallet_money_out}, saved payout_wallet", { user_id: @user.id, mangopay_result: wallets } if @user.payout_wallet_vid_changed?


    self.provision_payin_wallet  if @user.payin_wallet_vid.blank?
    self.provision_payout_wallet if @user.payout_wallet_vid.blank?

    @user.save!
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
      return nil
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
      return nil
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
      return nil
    end
    LOG.info "created bank_account:#{bank_account['Id']}", { user_id: @user.id, bank_account_vid: bank_account['Id'], mangopay_result: bank_account }

  end




### NOTE: DUMMY CODE BELOW THIS LINE


### UNIT TESTS are something i miss.

  # Get the balance of the payout wallet from mangopay.
  #def wallet_payout_balance
  #end

  #### By default, you can’t create a payin over EUR 2500


end