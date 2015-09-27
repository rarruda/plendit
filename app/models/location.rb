class Location < ActiveRecord::Base
  belongs_to :user


  validates :user, presence: true
  validates :address_line, presence: true
  validates :post_code, presence: true, format: { with: /\A[0-9]{4}\z/, message: "må være 4 siffer." }
  validate  :post_code_must_exist
  #validates :lat, presence: true, numericality: true
  #validates :lon, presence: true, numericality: true

  enum status: { active: 0, deleted: 1 }
  enum geo_precision: { unk: 0, high: 1, mid: 2, low: 3, post_code: 5 }

  default_scope { where.not( status: Location.statuses[:deleted] ).order(favorite: :desc, address_line: :asc) }


  before_validation :geocode_with_region, if: ->(obj){ obj.post_code.present? and ( obj.address_line_changed? or obj.post_code_changed? ) }

  before_save :set_city_from_postal_code



  def self.city_from_postal_code(postal_code)
    POSTAL_CODES[postal_code]
  end

  def is_geocoded?
    true if self.lat.is_a? Numeric and self.lon.is_a? Numeric and [:high, :mid, :low, :post_code].include? self.geo_precision
    false
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
    #https://developers.google.com/maps/documentation/geocoding/intro#GeocodingResponses
    #https://developers.google.com/maps/documentation/geocoding/intro#ComponentFiltering
    results = Geocoder.search( self.address_line, :params => { :components => "postal_code:#{self.post_code}|country:#{PLENDIT_COUNTRY_CODE}", :region => PLENDIT_COUNTRY_CODE, :language => PLENDIT_COUNTRY_CODE})
    if geo = results.first

      self.lat = geo.latitude
      self.lon = geo.longitude
      self.geo_precision_type = geo.geometry['location_type']
      self.geo_precision = case geo.geometry['location_type']
      when 'ROOFTOP'
        :high
      when 'RANGE_INTERPOLATED', 'GEOMETRIC_CENTER'
        :mid
      when 'APPROXIMATE'
        :low
      else
        :unk
      end

      logger.info "found address geocoding for location_id:#{self.id}"
    else
      logger.error "failed address geocoding for location_id:#{self.id}. Retrying based on post code alone."
      results = Geocoder.search( self.post_code, :params => { :components => "country:#{PLENDIT_COUNTRY_CODE}", :region => PLENDIT_COUNTRY_CODE, :language => PLENDIT_COUNTRY_CODE})

      if geo = results.first

        self.lat = geo.latitude
        self.lon = geo.longitude
        self.geo_precision_type = geo.geometry['location_type']
        self.geo_precision = :post_code

        logger.info "found post_code geocoding for location_id:#{self.id}"
      else
        logger.error "failed post_code geocoding for location_id:#{self.id}. This should never happen."
      end
    end
  end

end
