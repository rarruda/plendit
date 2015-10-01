include ActionView::Helpers::TextHelper

class Ad < ActiveRecord::Base
  include AASM
  include Searchable
  include PriceHumanizeable

  #acts_as_ordered_taggable
  acts_as_taggable

  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items, autosave: true, dependent: :destroy #will leave dangling links in old bookings/favorites.
  has_many :ad_images, autosave: true, dependent: :destroy
  has_many :bookings, through: :ad_items
  belongs_to :location

  enum status: { draft: 0, waiting_review: 1, published: 2, paused: 3, stopped: 4, suspended: 5, deleted: 6 }
  enum category: { bap: 0, motor: 1, realestate: 2 }

  accepts_nested_attributes_for :location, :reject_if => :all_blank

  validates :user,  presence: true
  validates :title, length: { in: 0..255 }, :unless => :new_record?
  validates :price, numericality: { greater_than_or_equal_to: 5_00, less_than: 1_000_000_00 }, :unless => :new_record?

  # todo: how to validate location present before publish?
  #validates :location, presence: true

  default_scope { where("ads.status NOT IN (?)", [ Ad.statuses[:suspended], Ad.statuses[:deleted] ]) }
  scope :for_user, ->(user) { where( user_id: user.id ) }
  scope :world_viewable, -> { where( status: Ad.statuses[:paused, :published] ) }
  scope :waiting_review, -> { where( status: Ad.statuses[:waiting_review] ) }
  scope :published,      -> { where( status: Ad.statuses[:published] ) }

  # If there were any changes, except in status, set status to draft:
  # BUG: works as long as you change any field. does not work when ad_images alone changes:
  # BUG: images can be changed and it will not send you back to edit modus
  before_save :edit, unless: "self.draft? || self.changes.except('status').empty?"

  after_create :create_ad_item

  # ES Settings for this model:
  # TODO: Need to configure separately settings and analyzers (for norwegian/current locale)
  settings index: { number_of_shards: 4 } do
    mappings do
      indexes :id,            type: :integer
      indexes :title,         type: :string, analyzer: 'norwegian', boost: 100
      indexes :body,          type: :string, analyzer: 'norwegian'
      indexes :geo_location,  type: :geo_point, lat_lon: true, geohash: true
      indexes :geo_precision, type: :string, index: :not_analyzed
      indexes :price,         type: :integer
      indexes :tags,          type: :string, analyzer: 'keyword'
      indexes :category,      type: :string
      indexes :insurance_required, type: :integer
      indexes :ad_images do
        indexes :id,          type: :integer
        indexes :description, type: :string, analyzer: 'norwegian'
        indexes :weight,      type: :integer
      end
      indexes :user do
        indexes :id,          type: :integer
      end
    end
  end

  aasm :column => :status, :enum => true do
    state :draft, :initial => true
    state :waiting_review
    state :published, :enter => :enter_published, :exit => :exit_published
    state :paused
    state :stopped
    state :suspended
    state :deleted

    event :submit_for_review do
      transitions :from => :draft, :to => :waiting_review
      after do
        # FIXME: do not ad be submitted for review if location does not have a latlon.
        LOG.error "submiting for review..."
      end
    end
    event :approve do
      transitions :from => :waiting_review, :to => :published, :guard => :ad_location_is_geocoded?
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
        LOG.info 'Preparing to edit'
      end
    end
    event :suspend do #reject?
      transitions :to => :suspended
      after do
        LOG.info 'ad is suspended. this is a black hole. there is no way out.'
      end
    end

    event :delete do
      transitions :to => :deleted

      after do
        # if ad doesn't have any references, delete it, otherwise, just
        # use the deleted flag to exclude it from things
        if is_deletable?
          self.destroy
          LOG.info 'ad deleted from database.'
        else
          LOG.info 'ad not deleted, only delted flag set'
        end

      end
    end
    #event :unsuspend do
    #  transitions :from => :suspended, :to => :waiting_review
    #end
  end


  def enter_published
    LOG.error ("ad published... it is now searchable after the toggle is switched.")
    __elasticsearch__.index_document
    ## TODO: notify user that his ad is now live.
  end

  def exit_published
    self.__elasticsearch__.delete_document ignore: 404
    LOG.info ">> no longer searchable."
  end



  def world_viewable?
    not ( self.stopped? or self.suspended? )
  end

  def related_ads_from_user
    self.user.ads.reject { |ad| ad.id == self.id }
  end

  # encapsulate ensure_require so we are ensure insurance on
  #   categories that insurance is mandatory.
  def insurance_required= arg
    if self.category == 'bap'
      super
    else
      super '1'
    end
  end

  def insurance_required
    if self.category == 'bap'
      super
    else
      '1'
    end
  end

  def is_favorite_of( user )
    fav_count = FavoriteAd.joins(:favorite_list).where(favorite_lists: { user_id: user }, ad: self.id ).count
    fav_count > 0 ? true : false
  end

  def is_favorited?
    not FavoriteAd.where(ad: self).empty?
  end

  def is_deletable?
    !self.is_favorited? && self.bookings.empty?
  end

  def ad_location_is_geocoded?
    return false if self.location.nil?
    self.location.is_geocoded?
  end

  # helper methods for generating urls for the three different image sizes, and which has the
  ## default fallback to stock images. (so that it will degrate nicely)
  def safe_image_url( size )
    stock_images = {
      thumb: ActionController::Base.helpers.image_path('no_image_180x120.jpg'),
      searchresult: ActionController::Base.helpers.image_path('no_image_450x300.jpg'),
      hero: ActionController::Base.helpers.image_path('no_image_900x600.jpg'),
      gallery: ActionController::Base.helpers.image_path('no_image_900x600.jpg')
    }

    unless stock_images.keys.include? size
      LOG.error "ERROR: wrong image size parameter, falling back to :searchresult"
      size = :searchresult
    end

    self.ad_images.count > 0 ? self.ad_images.first.image.url(size) : stock_images[size]
  end

  # JSON of how ElasticSearch should index this model
  # TODO: find out if we want more information on the Ad, and/or AdImages
  def as_indexed_json(options={})
    as_json(
      only: [:id, :title, :body, :category, :price ],
      include: { user: { only: :id }, ad_images: { only: [:id, :description, :weight] } },
      methods: [:tags, :geo_location, :geo_precision]
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
  def geo_precision
    self.location.geo_precision
  end

  # used in as_indexed_json
  def tags
    tag_list
  end

  def create_ad_item
    self.ad_items.build.save
  end

  # NOTE: this method is repeated as ad_to_param_pretty as an application helper due to
  # Elasticsearch::Model::Response::Result craziness.
  # look, its in the AdDecorator decorator too!
  def to_param
    if not self.title.blank?
      [self.id, self.title.parameterize].join('----')[0,64]
    else
      self.id.to_s
    end
  end
end
