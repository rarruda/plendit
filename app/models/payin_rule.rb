class PayinRule < ActiveRecord::Base
  belongs_to :ad

  validates :unit, presence: true
  validates :effective_from, numericality: { only_integer: true }
  validates :effective_from, numericality: { greater_than_or_equal_to: 1 }
  validates :effective_from, numericality: { less_than_or_equal_to: 24 }, if: "self.hour?"
  validates :effective_from, uniqueness:   { scope: [:ad, :unit], message: "Kan kun ha en pris per enhet." }
  validates :payin_amount, numericality: { only_integer: true }, unless: :new_record?
  validates :payin_amount, numericality: { less_than: 150_000_00, message: "Må være under 150.000 kr" }, unless: :new_record?
  validate  :validate_min_payin_amount,
    unless: "self.effective_from == 1",
    unless: :day?,
    unless: :new_record?


  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  scope :effective_from_asc, -> { order( :effective_from ) }
  scope :effective_from,     ->(unit, duration) do
    where( "unit = ? AND effective_from <= ?", PayinRule.units[unit.to_sym], duration )
    .order(effective_from: :desc)
    .limit(1)
  end

  def self.default_rule
    PayinRule.new(unit: 'day', effective_from: 1)
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


  def apply_max_discount amount
    if self.day? && self.effective_from >= 2
      Plendit::Application.config.x.insurance.max_discount_after_duration
        .map{ |d| ( amount >= d.first ) ? ( ( 1 - d.second ) * amount ).to_i : nil }
        .compact
        .max
    else
      nil
    end
  end

  #private
  def validate_min_payin_amount
    if self.day? && self.effective_from == 1
      min_payin_amount = Plendit::Application.config.x.insurance.max_discount_after_duration.map{|d| d.first}.min
    elsif self.day?
      first_day_payin_amount = self.ad.payin_rules.where( unit: PayinRule.units[:day], effective_from: 1 ).take.payin_amount
      min_payin_amount = self.apply_max_discount( first_day_payin_amount )
    else #self.hour?
      min_payin_amount = 35_00
    end

    if self.payin_amount < min_payin_amount
      errors.add(:payin_amount, "Må være minst #{ApplicationController.helpers.format_monetary_full min_payin_amount}")
    end
  end

  def min_duration_in_sec
    return 1.hour.to_i if self.hour?
    return 1.day.to_i  if self.day?

    raise 'unit must be set'
    nil
  end

end