class BookingItem < ActiveRecord::Base
  belongs_to :booking

  enum category: { reserved_for_ad_item: 1, insurance_fee: 2, insurance_deposit: 3, platform_fee: 4, vat: 5 }
end
