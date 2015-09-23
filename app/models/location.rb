class Location < ActiveRecord::Base
  belongs_to :user


  validates :user, presence: true
  validates :address_line, presence: true
  validates :post_code, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999 }
  # consider custom validator to we only accept valid post_codes.

  # FIXME: need to gracefully handle failed geocode lookups
  geocoded_by :address, :latitude => :lat, :longitude => :lon
  geocoder_options region: PLENDIT_COUNTRY_CODE, bounds: COUNTRY_GEO_BOUNDS


  enum status: { active: 0, deleted: 1 }


  default_scope { where.not( status: Location.statuses[:deleted] ).order(favorite: :desc, address_line: :asc) }


  after_validation :geocode, if: ->(obj){ obj.address_line.present? and obj.changed? }
  before_save :set_city_from_postal_code

  def address
    [address_line, post_code, "Norway"].compact.join(', ')
  end

  def self.city_from_postal_code(postal_code)
    POSTAL_CODES[postal_code]
  end

  private
  def set_city_from_postal_code
    self.city = Location.city_from_postal_code( self.post_code )
  end
end
