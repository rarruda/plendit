class PriceItem < ActiveRecord::Base
  belongs_to :price

  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 25_00, less_than: 1_000_000_00 }
  validates :unit, presence: true
  validates :effective_from_unit, numericality: { only_integer: true }
  validates :effective_from_unit, numericality: { greater_than_or_equal_to: 0 }
  validates :effective_from_unit, numericality: { less_than_or_equal_to: 23 }, if: "self.hour?"
  validates :effective_from_unit, uniqueness:   { scope: [:price, :unit], message: "can only have one price per effective_unit" }


  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  #private
  # validate price_item is saned compared to other price_items in this price structure.
  def amount_should_be_reasonable
    prev_price_item = PriceItem.where( "price_id = ? AND unit = ?", self.price, self.unit ).order(effective_from_unit: :desc).limit(1).first
    return true if prev_price_item.empty?

    if ( self.amount * self.effective_from_unit ) > prev_price_item.amount
      errors.add(:amount, "not allowed to have a total price cheaper over a longer period of #{self.unit}s then over a previous single #{self.unit}.")
      return false
    end
    true
  end

end
