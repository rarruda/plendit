class FavoriteList < ActiveRecord::Base
  belongs_to :user
  has_many :favorite_ads
end
