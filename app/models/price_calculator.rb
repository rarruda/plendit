class PriceCalculator
  include ActiveModel::Model

  attr_accessor :ad

  # two different ways to calculate duration:
  attr_accessor :starts_at, :ends_at
  attr_accessor :unit, :duration_in_unit

  # price_from_rules should probably get cached?
  #   recalculating it often could be a bit expensive.
  #attr_reader :price_from_rules

  validates :ad, presence: true

  validates :duration_in_unit, numericality: { only_integer: true } if "unit.present?"
  validates :unit, inclusion: { in: ['day','hour'] } if "duration_in_unit.present?"

  validate :validate_starts_at_before_ends_at if "self.ends_at.present? && self.starts_at.present?"

  def platform_fee
    ( price_from_rules * self.duration_in_unit * ( Plendit::Application.config.x.platform.fee_in_percent ) ).round
  end

  def insurance_fee
    return ( price_from_rules * self.duration_in_unit * ( Plendit::Application.config.x.insurance.price_in_percent[self.ad.category.to_sym] ) ).round if self.ad.insurance_required
    0_00
  end

  def reservation_amount
    Plendit::Application.config.x.insurance.reservation_value[self.ad.category.to_sym]
  end

  def payout_amount
    price_from_rules - ( self.platform_fee + self.insurance_fee )
  end




  private
  def price_from_rules
    price_rule.amount * self.duration_in_unit
  end

  # duration in seconds
  #  oportunistically save duration_in_unit
  def duration
    if self.unit.present? && self.duration_in_unit.present?
      ( self.duration_in_unit * ( self.unit == 'hour' ? 1.hour : 1.day ) ).to_i
    elsif
      # fallback, use interval between ends_at and starts_at
      duration_in_sec = self.ends_at.to_i - self.starts_at.to_i
      self.unit       = ( duration_in_sec < 24.hours ? 'hour' : 'day' )

      if self.unit == 'day'
        self.duration_in_unit = ( duration_in_sec / 1.day.to_f ).ceil
      else
        # note: this will always be >= 0 and <= 24
        self.duration_in_unit = ( duration_in_sec / 1.hour.to_f ).ceil
      end
    else
      raise "cannot compute duration. need more information."
    end
  end


  # find price rule.
  # NOTE: always round up.
  def price_rule
    if duration < 1.day.to_i
      # number of hours:
      effective_from_unit = ( duration / 1.hour ).ceil

      effective_price_rule = self.ad.price_rules.effective_from( 'hour', effective_from_unit ).first
      # found a hourly rule, use that:
      if effective_price_rule.present?
        return effective_price_rule
      else
        # use a day rule, with minimum possible number of days
        effective_from_unit = 1
      end
    else
      effective_from_unit = ( duration / 1.day ).ceil
    end

    self.ad.price_rules.effective_from( 'day', effective_from_unit ).first
  end

  def validate_starts_at_before_ends_at
      errors.add(:ends_at, "ends_at cannot be before starts_at") if self.ends_at < self.starts_at
  end
end