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

  def title_or(default)
    (self.title.nil? or self.title == "") ? default : self.title
  end

  def summary
    # fixme: There are a bunch of ways this can be improved. There might
    # be some gems for it already. For instance, end only at sentence
    # breaks and allow small overflows when close to full length.
    # Also, stick 240 in config somewhere?
    # Also, better whitespace / split / paragraph detection

    first_paragraph = self.body.split("\r\n\r\n").first
    if first_paragraph.nil?
      ""
    elsif first_paragraph.size > 240
      first_paragraph[0...240] + "..."
    else
      first_paragraph
    end
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
