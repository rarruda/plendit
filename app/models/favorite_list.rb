class FavoriteList < ActiveRecord::Base
  belongs_to :user
  has_many :favorite_ads
  accepts_nested_attributes_for :favorite_ads, :reject_if => :all_blank, :allow_destroy => true
end
