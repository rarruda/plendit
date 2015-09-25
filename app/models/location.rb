class Location < ActiveRecord::Base
  belongs_to :user


  validates :user, presence: true
  validates :address_line, presence: true
  validates :post_code, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999 }
  validate :post_code_must_exist

  # this validation wont work as :geocode_with_region is only called after validation.
  #validates [:lat,:lon], numericality: true ###, unless: Proc.new { |a| a.post_code.blank? }

  enum status: { active: 0, deleted: 1 }


  default_scope { where.not( status: Location.statuses[:deleted] ).order(favorite: :desc, address_line: :asc) }


  after_validation :geocode_with_region, if: ->(obj){ obj.address_line.present? and ( obj.address_line_changed? or obj.post_code_changed? ) }

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

  def post_code_must_exist
    if not POSTAL_CODES.keys.include? self.post_code
      errors.add(:post_code, "needs to be valid.")
    end
  end

  def geocode_with_region
    results = Geocoder.search(self.address, :params => { :region => PLENDIT_COUNTRY_CODE, :bounds => COUNTRY_GEO_BOUNDS, :language => PLENDIT_COUNTRY_CODE})
    if geo = results.first
      self.lat = geo.latitude
      self.lon = geo.longitude
    else
      logger.error "geocoding failed for location_id:#{self.id}."

      # FIXME: need to gracefully handle failed geocode lookups. Possiblities:
      #   1) Use geo location of the postal code?
      #   2) add validation that the geocoding worked, before allowing it to be saved? (eek?)
      #   3) use lots of time and get address line to be auto completed from a database?
      #   https://developers.google.com/maps/documentation/geocoding/intro#Results
      #results = Geocoder.search(self.address, :params => { :region => PLENDIT_COUNTRY_CODE, :bounds => COUNTRY_GEO_BOUNDS, :language => PLENDIT_COUNTRY_CODE})
      #if geo = results.first
      #  self.lat           = geo.latitude
      #  self.lon           = geo.longitude
      #  self.geoprecision  = geo.geometry['location_type']
      #end
    end
  end
end
