include ActionView::Helpers::TextHelper

class Ad < ActiveRecord::Base
  include AASM
  include Searchable

  belongs_to :user
  belongs_to :location
  has_many :ad_items,    autosave: true, dependent: :destroy #will leave dangling links in old bookings.
  has_many :ad_images,   autosave: true, dependent: :destroy
  has_many :bookings,    through: :ad_items
  has_many :payin_rules, autosave: true, dependent: :destroy
  has_many :favorite_ad, dependent: :destroy

  # suspended => refused
  enum status: { draft: 0, waiting_review: 1, published: 2, paused: 3, stopped: 4, refused: 5, suspended: 6, deleted: 11 }
  enum category: { bap: 0, motor: 1, realestate: 2, boat: 3 }

  enum registration_group: { not_motor: 0, car: 1, caravan: 2, scooter: 3, tractor: 4 }

  accepts_nested_attributes_for :location,    reject_if: :all_blank
  accepts_nested_attributes_for :payin_rules, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :ad_images,   reject_if: :all_blank, allow_destroy: true

  validates_associated :payin_rules, message: 'En av prisene du har oppgitt er ugyldige.'

  validates :user,  presence: true
  validates :title, length: { in: 3..255 , message: 'Annonsen må ha en tittel.' },
    unless: :new_record?

  validates :body, length: { in: 5..12000 , message: 'Annonsen må ha en beskrivelse.' },
    unless: :new_record?

  validates :registration_number, format: { with: /\A[a-zA-Z]{1,2}[0-9]{4,5}\z/, message: 'Annonsen må ha et gyldig reg.nr.' },
    unless: :new_record?,
    if:     :motor?

  validates :registration_group, presence: { message: 'Kjøretøyet må ha en underkategori.'},
    unless: :new_record?,
    if:     :motor?

  validates :estimated_value, numericality: { less_than: 250_000_00, allow_nil: true, message: 'Båt kan ha en maks antatt verdi på 250.000 kroner.'},
    unless: :new_record?,
    if:     :boat?

  validates :ad_images, presence: { message: 'Annonsen må ha minst ett bilde.' },
    unless: :new_record?
  # todo: runeh: use nested validations for this? As in validates_associated :payin_rules

  validate :boats_with_license_must_have_terms_acceptance_or_reg_num

  # todo: how to validate location present before publish?
  #validates :location, presence: true, unless: :new_record?

  validates :payin_rules, presence: true, unless: :new_record?

  default_scope { where("ads.status NOT IN (?)", [ Ad.statuses[:suspended], Ad.statuses[:deleted] ]) }
  scope :for_user, ->(user) { where( user_id: user.id ) }
  scope :world_viewable, -> { where( status: Ad.statuses[:paused, :published] ) }
  scope :waiting_review, -> { where( status: Ad.statuses[:waiting_review] ) }
  scope :published,      -> { where( status: Ad.statuses[:published] ) }
  scope :never_edited,   -> { where( "status = 0 AND title IS NULL AND body IS NULL AND location_id IS NULL AND created_at = updated_at" ) }



  # If there were any changes, except in status or refusal_reason, set status to draft:
  before_save :edit, unless: "self.draft? || self.changes.except('status','refusal_reason').empty?"

  after_create :create_payin_rule

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
      indexes :category,      type: :string
      indexes :main_image_url,type: :string, index: :not_analyzed
      indexes :ad_images do
        indexes :id,          type: :integer
        indexes :description, type: :string, analyzer: 'norwegian'
        indexes :weight,      type: :integer
      end
      indexes :user do
        indexes :id,          type: :integer
        indexes :avatar_url,  type: :string, index: :not_analyzed
      end
    end
  end

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :waiting_review
    state :published, enter: :enter_published, exit: :exit_published
    state :paused
    state :stopped
    state :suspended
    state :refused
    state :deleted

    after_all_transitions :log_status_change

    event :submit_for_review do
      transitions from: :draft, to: :waiting_review, guard: :valid?
    end
    event :approve do
      # It is imperative to only approve ads which have geocoded locations.
      transitions from: :waiting_review, to: :published, guard: :is_location_geocoded?
    end
    event :refuse do
      transitions from: [:published, :waiting_review], to: :refused
      after do
        LOG.info message:'ad is refused. Hopefully there is a reason so that the user can do something about it.'
      end
    end

    event :pause do
      transitions from: [:published, :stopped], to: :paused
    end
    event :stop do
      transitions from: [:published, :paused], to: :stopped
    end
    event :resume do
      transitions from: [:paused, :stopped], to: :published
    end
    event :edit do
      transitions from: [:waiting_review, :published, :paused, :stopped, :refused], to: :draft
    end

    event :suspend do
      transitions to: :suspended
      after do
        LOG.info message:'ad is suspended. this is a black hole. there is no way out. the use gets no feedback either.'
      end
    end

    event :delete do
      transitions to: :deleted

      after do
        # if ad doesn't have any references, delete it, otherwise, just
        # use the deleted flag to exclude it from things
        if is_deletable?
          self.destroy
          LOG.info message:'ad deleted from database.'
        else
          LOG.info message:'ad not deleted, only deleted flag set'
        end

      end
    end
    #event :unsuspend do
    #  transitions from: :suspended, to: :waiting_review
    #end
  end


  def enter_published
    LOG.error message: 'ad published... it is now searchable after the toggle is switched.'
    __elasticsearch__.index_document
    ## TODO: notify user that his ad is now live.
  end

  def exit_published
    self.__elasticsearch__.delete_document ignore: 404
    LOG.info message:'no longer searchable.', ad_id: self.id
  end

  def world_viewable?
    not ( self.stopped? or self.suspended? or self.refused? )
  end

  def related_ads_from_user
    self.user.ads.reject { |ad| ad.id == self.id }
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

  def is_location_geocoded?
    self.location.nil? ? false : self.location.is_geocoded?
  end

  # helper methods for generating urls for the three different image sizes, and which has the
  ## default fallback to stock images. (so that it will degrate nicely)
  def safe_image_url( size )
    stock_images = {
      thumb:        ActionController::Base.helpers.image_path('no_image_180x120.jpg'),
      searchresult: ActionController::Base.helpers.image_path('no_image_450x300.jpg'),
      hero:         ActionController::Base.helpers.image_path('no_image_900x600.jpg'),
      gallery:      ActionController::Base.helpers.image_path('no_image_900x600.jpg')
    }

    unless stock_images.keys.include? size
      LOG.error message: 'ERROR: wrong image size parameter, falling back to :searchresult'
      size = :searchresult
    end

    # fixme: Check that .first here users weight!
    self.ad_images.length > 0 ? self.ad_images.first.image.url(size) : stock_images[size]
  end

  # JSON of how ElasticSearch should index this model
  # TODO: find out if we want more information on the Ad, and/or AdImages
  def as_indexed_json(options={})
    entry = Jbuilder.encode do |json|
      json.(self, :id, :title, :body, :category, :price, :geo_precision, :geo_location)
      json.images self.ad_images, :id, :description, :weight
      json.main_image_url self.safe_image_url(:searchresult)
      json.user do |user|
        json.id self.user.id
        # FIXME: its very very ugly to index the feedback_score with the ad.
        json.rating self.user.feedback_score
        json.avatar_url self.user.safe_avatar_url
      end
    end
    # this is silly, but it's expected that as_indexed_json returns an
    # object, not a json strung that jbuilder gives us.
    JSON.parse(entry)
  end

  # method to give the same result as what we had before in the Ad Model.
  # used in as_indexed_json
  def price
    self.payin_rules.find(&:required_rule?).payin_amount
  end

  def estimated_value_in_h
    ApplicationController.helpers.integer_to_decimal self.estimated_value
  end

  def estimated_value_in_h=(ev)
    self.estimated_value = ApplicationController.helpers.decimal_to_integer(ev)
  end

  def main_payin_rule
    self.payin_rules.find &:required_rule?
  end

  def secondary_payin_rules
    self.payin_rules.sort_by(&:effective_from).reject(&:required_rule?)
  end

  def has_new_location
    self.location.present? && self.location.ads.size == 1
  end

  def location_guid
    self.location.guid if self.location.present?
    nil
  end

  def location_guid=( guid )
    self.location_id = Location.all.where( guid: guid ).take.id
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

  def booking_calculator
    BookingCalculator.new(ad: self)
  end

  private

  def boats_with_license_must_have_terms_acceptance_or_reg_num
    if self.boat? && self.boat_license_required && self.registration_number.empty? && !self.accepted_boat_insurance_terms
      self.errors.add(:boat_license_required, 'Du må enten fylle inn registreringsnummer, eller akseptere forsikringsvilkårene')
    end
  end

  def create_ad_item
    self.ad_items.build.save
  end

  def create_payin_rule
    self.payin_rules.build(unit: 'day', effective_from: 1).save
  end

  def log_status_change
    LOG.info message: "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event}) for ad_id: #{self.id}", ad_id: self.id
  end
end
