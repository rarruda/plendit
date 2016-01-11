module UserPaymentCardsHelper

    def payment_card_icon card_type
        if card_type == 'VISA'
          icon 'cc-visa', class: 'fa-lg'
        elsif card_type == 'MASTERCARD'
          icon 'cc-mastercard', class: 'fa-lg'
        else
          icon 'credit-card', class: 'fa-lg'
        end
    end


end
