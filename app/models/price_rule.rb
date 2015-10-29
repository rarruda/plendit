class PriceRule < ActiveRecord::Base
  belongs_to :ad

  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 25_00, less_than: 1_000_000_00 }
  validates :unit, presence: true
  validates :effective_from_unit, numericality: { only_integer: true }
  validates :effective_from_unit, numericality: { greater_than_or_equal_to: 1 }
  validates :effective_from_unit, numericality: { less_than_or_equal_to: 24 }, if: "self.hour?"
  validates :effective_from_unit, uniqueness:   { scope: [:ad, :unit], message: "can only have one price per effective_unit" }

  validate  :amount_should_be_reasonable

  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  def self.default_rule
    PriceRule.new(unit: 'day', amount: 25_00, effective_from_unit: 1)
  end

  scope :effective_from, ->(unit, duration) do
    where( "unit = ? AND effective_from_unit <= ?", PriceRule.units[unit.to_sym], duration )
    .order(effective_from_unit: :desc)
    .limit(1)
  end

  def required?
    self.day? && self.effective_from_unit == 1
  end

  def amount_in_h
    return nil if self.amount.nil?
    ( ( self.amount / 100).to_i + ( self.amount / 100.0  ).modulo(1) )
  end

  # save prices in integer, from human format input
  def amount_in_h=( _price )
    self.amount = ( _price.to_f * 100 ).to_i
  end

  #private
  # validate price_rule is saned compared to other price_rules in this price structure.
  def amount_should_be_reasonable
    prev_price_rule = PriceRule.where( "ad_id = ? AND unit = ? AND effective_from_unit < ?",
      self.ad_id, PriceRule.units[self.unit.to_sym], self.effective_from_unit ).first
    return true if prev_price_rule.nil?

    if ( self.amount * self.effective_from_unit ) < prev_price_rule.amount
      errors.add(:amount, "not allowed to have a total price cheaper over a longer period of #{self.unit}s then over a previous single #{self.unit}.")
      return false
    end
    true
  end

end
