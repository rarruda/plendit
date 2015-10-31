class PayinRule < ActiveRecord::Base
  belongs_to :ad

  validates :payin_amount, numericality: { only_integer: true, greater_than_or_equal_to: 25_00, less_than: 1_000_000_00 }
  validates :unit, presence: true
  validates :effective_from, numericality: { only_integer: true }
  validates :effective_from, numericality: { greater_than_or_equal_to: 1 }
  validates :effective_from, numericality: { less_than_or_equal_to: 24 }, if: "self.hour?"
  validates :effective_from, uniqueness:   { scope: [:ad, :unit], message: "can only have one price per effective_unit" }

  validate  :payin_amount_should_be_reasonable

  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  def self.default_rule
    PriceRule.new(unit: 'day', payin_amount: 25_00, effective_from: 1)
  end

  scope :effective_from, ->(unit, duration) do
    where( "unit = ? AND effective_from <= ?", PriceRule.units[unit.to_sym], duration )
    .order(effective_from: :desc)
    .limit(1)
  end

  def required?
    self.day? && self.effective_from == 1
  end

  def payin_amount_in_h
    return nil if self.payin_amount.nil?
    ( ( self.payin_amount / 100).to_i + ( self.payin_amount / 100.0  ).modulo(1) )
  end

  # save prices in integer, from human format input
  def payin_amount_in_h=( _payin_amount )
    self.payin_amount = ( _payin_amount.to_f * 100 ).to_i
  end



  def payin_amount_for_duration duration = min_duration_in_sec
    case self.unit
    when 'hour'
      num_hours = ( duration / 1.hour.to_f ).ceil
      return ( num_hours * self.payin_amount ).round if num_hours >= self.effective_from
    when 'day'
      num_days = ( duration / 1.day.to_f ).ceil
      return ( num_days * self.payin_amount ).round if num_days >= self.effective_from
    else
      raise 'invalid unit'
    end
    nil
  end

  private
  def min_duration_in_sec
    return 1.hour.to_i if self.hour?
    return 1.day.to_i  if self.day?

    raise 'unit must be set'
    nil
  end

  # validate payin_rule is saned compared to other payin_rules in this price structure.
  def payin_amount_should_be_reasonable
    prev_payin_rule = PayinRule.where( "ad_id = ? AND unit = ? AND effective_from < ?",
      self.ad_id, PayinRule.units[self.unit.to_sym], self.effective_from ).first
    return true if prev_payin_rule.nil?

    if ( self.payin_amount * self.effective_from ) < prev_payin_rule.payin_amount
      errors.add(:payin_amount, "not allowed to have a total price cheaper over a longer period of #{self.unit}s then over a previous single #{self.unit}.")
      return false
    end
    true
  end

end
