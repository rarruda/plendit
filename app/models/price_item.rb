class PriceItem < ActiveRecord::Base
  belongs_to :price

  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 25_00, less_than: 1_000_000_00 }
  validates :effective_from_unit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :effective_from_unit, numericality: { less_than_or_equal_to: 23 }, if: "self.hour?"

  #FIXME: validate price_item is saned compared to other price_items in this price structure.

  enum unit: { unk_unit: 0, hour: 1, day: 2 }

end
