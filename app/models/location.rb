class Location < ActiveRecord::Base
  belongs_to :user
  geocoded_by :address, :latitude => :lat, :longitude => :lon
  after_validation :geocode, if: ->(obj){ obj.address_line.present? and obj.changed? }

  def address
    [address_line, city, state, "Norway"].compact.join(', ')
  end
end
