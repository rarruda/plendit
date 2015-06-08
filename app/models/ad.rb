include ActionView::Helpers::TextHelper

class Ad < ActiveRecord::Base
  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
  has_many :ad_images
  belongs_to :location

  validates :user,  presence: true
  validates :title, length: { in: 0..255 }, :unless => :new_record?
  validates :price, numericality: { greater_than_or_equal_to: 0 }, :unless => :new_record?

  # todo: how to validate location present before publish?
  #validates :location, presence: true

  def related_ads_from_user
    self.user.ads.reject { |ad| ad.id == self.id }
  end

  def is_favorite_of( user )
    fav_count = FavoriteAd.joins(:favorite_list).where(favorite_lists: { user_id: user }, ad: self.id ).count
    fav_count > 0 ? true : false
  end

  def summary
    truncate( self.body , line_width: 240 )
  end

  # helper methods for generating urls for the three different image sizes, and which has the
  ## default fallback to stock images. (so that it will degrate nicely)
  def image_url_with_fallback( size )
    stock_images = {
      :thumb => "user_more_ads_1.jpg",
      :medium => "ads/ad1/ad_image_1.jpg",
      :mediumplus => "",
    }

    if not stock_images.keys.include? size
      logger.error "ERROR: wrong image size parameter, falling back to :medium"
      size = :medium
    end

    self.ad_images.count > 0 ? self.ad_images.first.image.url(size) : stock_images[size]
  end

end
