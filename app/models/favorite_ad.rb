class FavoriteAd < ActiveRecord::Base
  belongs_to :favorite_list
  belongs_to :ad
end
