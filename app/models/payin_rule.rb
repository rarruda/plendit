class PayinRule < ActiveRecord::Base
  belongs_to :ad

  validates :payin_amount, numericality: { only_integer: true }, :unless => :new_record?
  validates :payin_amount, numericality: { greater_than_or_equal_to: 49_00, message: "must be at least 49 kr" }, unless: :new_record?
  validates :payin_amount, numericality: { less_than: 150_000_00, message: "must be at less then 150.000 kr" }, unless: :new_record?
  validates :unit, presence: true
  validates :effective_from, numericality: { only_integer: true }
  validates :effective_from, numericality: { greater_than_or_equal_to: 1 }
  validates :effective_from, numericality: { less_than_or_equal_to: 24 }, if: "self.hour?"
  validates :effective_from, uniqueness:   { scope: [:ad, :unit], message: "can only have one price per effective_unit" }

  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  scope :effective_from_asc, -> { order( :effective_from ) }


  def self.default_rule
    PayinRule.new(unit: 'day', effective_from: 1)
  end

  def self.single_amount_rule payin_amount, ad
    PayinRule.new(unit: 'day', effective_from: 1, payin_amount: payin_amount)
  end

  scope :effective_from, ->(unit, duration) do
    where( "unit = ? AND effective_from <= ?", PayinRule.units[unit.to_sym], duration )
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
    self.payin_amount = ( _payin_amount.to_f * 100 ).round
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

end
