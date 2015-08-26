class Location < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :address_line, presence: true
  validates :post_code, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999 }
  geocoded_by :address, :latitude => :lat, :longitude => :lon

  enum status: { active: 0, deleted: 1 }

  after_validation :geocode, if: ->(obj){ obj.address_line.present? and obj.changed? }
  before_save :set_city_from_postal_code

  # TODO (RA): fix: probably a performance / memory hog:
  @@postal_codes = YAML.load_file("#{Rails.root}/config/data/postal_codes.yml")

  def address
    [address_line, post_code, "Norway"].compact.join(', ')
  end

  def self.city_from_postal_code(postal_code)
    @@postal_codes[postal_code]
  end

  private
  def set_city_from_postal_code
    self.city = Location.city_from_postal_code( self.post_code )
  end
end
