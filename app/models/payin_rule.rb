class PayinRule < ActiveRecord::Base
  belongs_to :ad

  validates :guid,           uniqueness: true
  validates :ad,             presence: true
  validates :unit,           presence: true
  validates :effective_from, numericality: { only_integer: true,    message: "Antall dager må være en tall." }
  validates :effective_from, numericality: { greater_than_or_equal_to: 1, message: "Antall dager må være minst 1." }
  validates :effective_from, numericality: { less_than_or_equal_to:   24, message: "Antall timer må være mindre enn 24."  }, if: :hour?
  validates :effective_from, uniqueness:   { scope: [:ad, :unit],   message: "Kan kun ha en pris per enhet." }
  validates :payin_amount,   numericality: { only_integer: true,    message: "Pris må være enn tall." }, allow_blank: true,
    unless: :new_record?
  validates :payin_amount,   numericality: { less_than: 150_000_00, message: "Pris må være under 150.000 kr." }, allow_blank: true,
    unless: :new_record?

  # validate min_payin_amount if not required_rule?
  validate  :validate_min_payin_amount,
    unless: :required_rule?


  before_validation :set_defaults, if: :new_record?
  before_validation :set_guid,     on: :create

  enum unit: { unk_unit: 0, hour: 1, day: 2 }

  scope :required_rule,      -> { where( "unit = ? AND effective_from = 1", PayinRule.units[:day])}
  scope :effective_from_asc, -> { order( :effective_from ) }
  scope :effective_from,     ->(unit, duration) do
    where( "unit = ? AND effective_from <= ?", PayinRule.units[unit.to_sym], duration )
    .order(effective_from: :desc)
    .limit(1)
  end

  # is this the mandatory/required payin_rule?
  def required_rule?
    self.day? && self.effective_from == 1
  end

  # FIXME: code duplicated at booking model:
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


  # given an price_for_a_day, return that's the minimum price that
  #  can be offered. (to deny very large discounts, which could make
  #  insurance inviable).
  def apply_max_discount amount
    if self.day? && self.effective_from >= 2
      # map through the max_discount array of [<min_value_for_discount_to_be_applicable,max_discount_pct>]
      # and result in [<discounted_value_if_possible_or_nil>]
      # if no discount works, it will return nil.
      Plendit::Application.config.x.insurance.max_discount_after_duration
        .map{ |d| ( amount >= d.first ) ? ( ( 1 - d.second ) * amount ).to_i : nil }
        .compact
        .max
    else
      nil
    end
  end

  def to_param
    self.guid
  end

  private
  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end

  # default rule when nothing is specified:
  def set_defaults
    self.unit ||= 'day'
    self.effective_from ||= 1
  end

  def validate_min_payin_amount
    max_discount_after_duration = case self.ad.category
    when 'boat'
      Plendit::Application.config.x.insurance.max_discount_after_duration_boat
    else
      Plendit::Application.config.x.insurance.max_discount_after_duration
    end

    if self.day? && self.effective_from == 1
      min_payin_amount = max_discount_after_duration.map{|d| d.first}.min
    elsif self.day?
      first_day_payin_amount = self.ad.payin_rules.required_rule.take.payin_amount
      min_payin_amount = self.apply_max_discount( first_day_payin_amount )
    else #self.hour?
      min_payin_amount = 35_00
    end

    # only reason to have min_payin_amount nil, is if "self.effective_from >=2 && self.day?" and
    #  no required_rule? exists yet.
    if min_payin_amount.nil? && ! self.required_rule?
      errors.add(:payin_amount, "Du må oppgi en pris per dag før du kan opprette en rabattpris")
    elsif self.payin_amount.nil? || self.payin_amount < min_payin_amount
      errors.add(:payin_amount, "Pris må være minst #{ApplicationController.helpers.format_monetary_full_pretty min_payin_amount}")
    end
  end

  def min_duration_in_sec
    return 1.hour.to_i if self.hour?
    return 1.day.to_i  if self.day?

    raise 'unit must be set'
    nil
  end

end