class Price < ActiveRecord::Base
  has_one :ad
  has_many :price_items

  validates_associated :price_items

  # calculate price based on qty and unit
  def calculate( qty, unit = 'day')
  end
end
