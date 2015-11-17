class BookingCalculator
  include ActiveModel::Model

  attr_accessor :ad
  attr_accessor :starts_at, :ends_at

  validates :ad, presence: true
  #validates :starts_at, presence: true
  #validates :ends_at,   presence: true

  validate :validate_starts_at_before_ends_at, if: "self.ends_at.present? && self.starts_at.present?"

  def platform_fee payin_rule = nil
    ( self.payin_amount(payin_rule) * Plendit::Application.config.x.platform.fee_in_percent ).round
  end

  def insurance_fee payin_rule = nil
    ( self.payin_amount(payin_rule) * Plendit::Application.config.x.insurance.price_in_percent[self.ad.category.to_sym] ).round
  end

  def total_fee payin_rule = nil
    self.platform_fee(payin_rule) + self.insurance_fee(payin_rule)
  end

  def max_insurance_coverage payin_rule = nil
    ( self.payin_amount(payin_rule) * Plendit::Application.config.x.insurance.max_coverage_factor[self.ad.category.to_sym] ).round
  end

  def reservation_amount
    Plendit::Application.config.x.insurance.reservation_value[self.ad.category.to_sym]
  end

  def payout_amount payin_rule = nil
    payin_amount(payin_rule) - ( self.platform_fee(payin_rule) + self.insurance_fee(payin_rule) )
  end

  # optional argument to specify calculations on a single payin_rule
  def payin_amount payin_rule = nil
    if payin_rule.present?
      raise "payin_rule is invalid. it does not respond to payin_amount" unless payin_rule.respond_to? 'payin_amount'

      payin_rule.payin_amount || 0
    else
      self.ad.payin_rules
        .map { |e| e.payin_amount_for_duration duration }
        .compact
        .min
    end
  end

  private
  def duration
    ( self.ends_at - self.starts_at ).to_i
  end

  def validate_starts_at_before_ends_at
      errors.add(:ends_at, "ends_at cannot be before starts_at") if self.ends_at < self.starts_at
  end
end