class FavoriteAd < ActiveRecord::Base
  belongs_to :favorite_list
  belongs_to :ad
  has_one :user, through: :favorite_list
end
