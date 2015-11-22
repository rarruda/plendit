require 'mangopay'

# This service should be used via a delayed job of some sort, for most operations.
class MangopayService

  def initialize(user)
    @user = user
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



### NOTE: DUMMY CODE BELOW THIS LINE


### UNIT TESTS are something i miss.

  # Get the balance of the payout wallet from mangopay.
  #def wallet_payout_balance
  #end

  #### By default, you can’t create a payin over EUR 2500


end