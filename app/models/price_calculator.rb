class PriceCalculator
  include ActiveModel::Model

  attr_accessor :ad

  # two different ways to calculate duration:
  attr_accessor :starts_at, :ends_at
  attr_accessor :unit, :duration_in_unit


  validates :ad, presence: true

  validates :duration_in_unit, numericality: { only_integer: true }, if: "unit.present?"
  validates :unit, inclusion: { in: ['day','hour'] }, if: "duration_in_unit.present?"

  validate :validate_starts_at_before_ends_at, if: "self.ends_at.present? && self.starts_at.present?"

  def platform_fee
    ( price_from_rules * Plendit::Application.config.x.platform.fee_in_percent ).round
  end

  def insurance_fee
    return ( price_from_rules * Plendit::Application.config.x.insurance.price_in_percent[self.ad.category.to_sym] ).round if self.ad.insurance_required
    0_00
  end

  def reservation_amount
    Plendit::Application.config.x.insurance.reservation_value[self.ad.category.to_sym]
  end

  def payout_amount
    price_from_rules - ( self.platform_fee + self.insurance_fee )
  end



  def price_from_rules
    self.ad.price_rules
      .map { |e| e.price_for_duration duration }
      .reject { |e| e.nil? }
      .min

  end

#  private

  # duration in seconds
  # (either from :unit + :duration_in_unit or from :starts_at + :ends_at)
  #  oportunistically save :duration_in_unit && :unit
  def duration
    if self.unit.present? && self.duration_in_unit.present?
      ( self.duration_in_unit * ( self.unit == 'hour' ? 1.hour : 1.day ) ).to_i
    elsif self.starts_at.present? && self.starts_at.present?
      duration_in_sec = ( self.ends_at - self.starts_at ).to_i

      if duration_in_sec >= 24.hours
        self.unit = 'day'
        self.duration_in_unit = ( duration_in_sec / 1.day.to_f ).ceil
      else
        # note: this will always be >= 0 and <= 24
        self.unit = 'hour'
        self.duration_in_unit = ( duration_in_sec / 1.hour.to_f ).ceil
      end
      duration_in_sec
    else
      raise "cannot compute duration. need more information."
    end
  end


  def validate_starts_at_before_ends_at
      errors.add(:ends_at, "ends_at cannot be before starts_at") if self.ends_at < self.starts_at
  end
end