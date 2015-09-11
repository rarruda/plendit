module PriceHumanizeable
  extend ActiveSupport::Concern

  included do
    # show prices in human format (converted from integer)
    def price_in_h()
      ( ( self.price / 100).to_i + ( self.price/100.0  ).modulo(1) )
    end

    # save prices in integer, from human format input
    def price_in_h=( _price )
      self.price = ( _price.to_f * 100 ).to_i
    end
  end
end