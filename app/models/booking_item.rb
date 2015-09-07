class BookingItem < ActiveRecord::Base
  belongs_to :booking

  enum category: { reserved_for_ad: 1, insurance: 2, platform_fee: 3, vat: 5 }
end
