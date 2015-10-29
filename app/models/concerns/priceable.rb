module Priceable
  extend ActiveSupport::Concern

  included do
    # show prices in human format (converted from integer)
    def price_in_h()
      return nil if self.price.nil?
      ( ( self.price / 100).to_i + ( self.price/100.0  ).modulo(1) )
    end

    # save prices in integer, from human format input
    def price_in_h=( _price )
      self.price = ( _price.to_f * 100 ).to_i
    end

    private
    # just return a int price from a float price
    def self.h_to_number( human_price )
      ( human_price.to_f * 100 ).to_i
    end
  end
end