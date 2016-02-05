class Location < ActiveRecord::Base
  belongs_to :user

  has_many :ads

  validates :guid,         presence: true, uniqueness: true
  validates :user,         presence: true
  validates :address_line, presence: { mesage: "Addresse kan ikke være blank." }
  validates :post_code,    presence: true, format: { with: /\A[0-9]{4}\z/, message: "Postnummer må være 4 siffer." }
  validate  :post_code_must_exist
  #validates :lat, presence: true, numericality: true
  #validates :lon, presence: true, numericality: true

  enum status: { active: 0, deleted: 1 }
  enum geo_precision: { unk: 0, high: 1, mid: 2, low: 3, post_code: 5 }

  default_scope { where.not( status: Location.statuses[:deleted] ).order(favorite: :desc, address_line: :asc) }


  before_validation :geocode_with_region, if: ->(obj){ obj.post_code.present? && ( obj.address_line_changed? || obj.post_code_changed? ) }

  before_validation :set_guid, if: :new_record?

  before_save :set_city_from_postal_code


  def to_s_pretty
    "#{self.address_line}, #{self.post_code} #{self.city}"
  end

  def self.city_from_postal_code(postal_code)
    POSTAL_CODES[postal_code]
  end

  def is_geocoded?
    ( self.lat.is_a? Numeric ) && ( self.lon.is_a? Numeric ) && ( ['high', 'mid', 'low', 'post_code'].include? self.geo_precision )
  end

  def delete!
    self.update_columns(status: Location.statuses[:deleted])
  end

  def in_use?
    self.ads.any?
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

  def set_city_from_postal_code
    self.city = Location.city_from_postal_code( self.post_code )
  end

  def post_code_must_exist
    if not POSTAL_CODES.keys.include? self.post_code
      errors.add(:post_code, "Postnummer må være gyldig.")
    end
  end

  def geocode_with_region
    #https://developers.google.com/maps/documentation/geocoding/intro#GeocodingResponses
    #https://developers.google.com/maps/documentation/geocoding/intro#ComponentFiltering
    results = Geocoder.search( self.address_line, params: {
      components: "postal_code:#{self.post_code}|country:#{PLENDIT_COUNTRY_CODE}",
      region:     PLENDIT_COUNTRY_CODE,
      language:   PLENDIT_COUNTRY_CODE
      }
    )

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

      LOG.info message: "found address geocoding for location_id:#{self.id}", location_id: self.id
    else
      LOG.error message: "failed address geocoding for location_id:#{self.id}. Retrying based on post code alone.", location_id: self.id
      results = Geocoder.search( self.post_code, params: { components: "country:#{PLENDIT_COUNTRY_CODE}", region: PLENDIT_COUNTRY_CODE, language: PLENDIT_COUNTRY_CODE})

      if geo = results.first

        self.lat = geo.latitude
        self.lon = geo.longitude
        self.geo_precision_type = geo.geometry['location_type']
        self.geo_precision = :post_code

        LOG.info message: "found post_code geocoding for location_id:#{self.id}", location_id: self.id
      else
        LOG.error message: "failed post_code geocoding for location_id:#{self.id}. This should never happen.", location_id: self.id
      end
    end
  end

end