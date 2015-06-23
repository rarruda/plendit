include ActionView::Helpers::TextHelper

class Ad < ActiveRecord::Base
  include AASM
  include Searchable

  #acts_as_ordered_taggable
  acts_as_taggable

  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
  has_many :ad_images
  belongs_to :location

  enum status: { draft: 0, waiting_review: 1, published: 2, paused: 3, stopped: 4, suspended: 5 }

  accepts_nested_attributes_for :location, :reject_if => :all_blank

  validates :user,  presence: true
  validates :title, length: { in: 0..255 }, :unless => :new_record?
  validates :price, numericality: { greater_than_or_equal_to: 0 }, :unless => :new_record?

  # todo: how to validate location present before publish?
  #validates :location, presence: true

  default_scope { where.not( status: Ad.statuses[:suspended] ) }
  scope :for_user, ->(user) { where( user_id: user.id ) }
  scope :world_viewable, -> { where( status: Ad.statuses[:paused, :published] ) }

  # If there were any changes, except in status, set status to draft:
  before_save :edit, unless: "self.changes.except('status').empty?"

  aasm :column => :status, :enum => true do
    state :draft, :initial => true
    state :waiting_review
    state :published, :enter => :enter_published, :exit => :exit_published
    state :paused
    state :stopped
    state :suspended

    event :submit_for_review do
      transitions :from => :draft, :to => :waiting_review
      after do
        logger.error "submiting for review..."
      end
    end
    event :approve do
      transitions :from => :waiting_review, :to => :published
    end
    event :pause do
      transitions :from => [:published, :stopped], :to => :paused
    end
    event :stop do
      transitions :from => [:published, :paused], :to => :stopped
    end
    event :resume do
      transitions :from => [:paused, :stopped], :to => :published
    end
    event :edit do
      transitions :from => [:waiting_review, :published, :paused, :stopped], :to => :draft
      before do
        logger.info 'Preparing to edit'
      end
    end
    event :suspend do #reject?
      transitions :to => :suspended
      after do
        logger.info 'ad is suspended. this is a black hole. there is no way out.'
      end
    end
    #event :unsuspend do
    #  transitions :from => :suspended, :to => :waiting_review
    #end
  end


  def enter_published
    logger.error ("ad published... it is now searchable after the toggle is switched.")
    __elasticsearch__.index_document
    ## TODO: notify user that his ad is now live.
  end

  def exit_published
    self.__elasticsearch__.delete_document ignore: 404
    logger.info ">> no longer searchable."
  end


  def world_viewable?
    not ( self.stopped? or self.suspended? )
  end

  def searcheable?
    self.published?
  end

  # now as part of Searchable/ES
  #def self.search q
  #  Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{q}%", "%#{q}%" )
  #end

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
      thumb: 'no_image_180x120.jpg',
      searchresult: 'no_image_450x300.jpg',
      hero: 'no_image_900x600.jpg',
      gallery: 'no_image_900x600.jpg'
    }

    if not stock_images.keys.include? size
      logger.error "ERROR: wrong image size parameter, falling back to :searchresult"
      size = :searchresult
    end

    self.ad_images.count > 0 ? self.ad_images.first.image.url(size) : stock_images[size]
  end

  # JSON of how ElasticSearch should index this model
  # TODO: find out if we want more information on the Ad, and/or AdImages
  def as_indexed_json(options={})
    as_json(
      only: [:id, :title, :body, :price ],
      include: { user: { only: :id }, ad_images: { only: [:id, :description] } },
      methods: [:tags, :geo_location]
    )
  end

  # used in as_indexed_json
  def geo_location
    if self.location
      { lat: self.location.lat, lon: self.location.lon }
    else
      nil
    end
  end

  # used in as_indexed_json
  def tags
    tag_list
  end
end
