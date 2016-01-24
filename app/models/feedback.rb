class Feedback < ActiveRecord::Base
  belongs_to :booking
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user,   class_name: 'User'
  #has_one :user, through: :booking

  validates :booking, presence: true
  validates :booking, uniqueness: { scope: [ :booking_id, :from_user_id ],
    message: 'user can only write one feedback/rating' }
  validates :score,   presence: true
  validates :score,   numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  validate  :from_user_is_valid
  validate  :to_user_is_valid

  scope :from_user,  ->(user) { where( from_user_id: user.id ) }
  scope :to_user,    ->(user) { where( to_user_id:   user.id ) }

  # dont try setting to_user_id, as it get overridden here.
  before_validation :set_to_user_id, on: :create

  # returns true if parent booking has status archived
  def visible?
    self.booking.archived?
  end

  # can be edited only if parent booking has status ended
  def editable?
    self.booking.ended?
  end

  private
  def from_user_is_valid
    unless [ self.booking.from_user_id, self.booking.ad.user_id ].include? self.from_user_id
      errors.add(:from_user, 'Den som skriver rating må være enten leietaker eller utleier. ')
    end
  end

  def to_user_is_valid
    unless [ self.booking.from_user_id, self.booking.ad.user_id ].include? self.to_user_id
      errors.add(:to_user, 'Mottaker må være en del av leieforholdet.')
    end
  end

  def set_to_user_id
    if self.booking.from_user_id == self.from_user_id
      # feedback comes from the renter, so its meant to owner
      self.to_user_id = self.booking.ad.user_id
    else
      # feedback comes from owner, so it goes to renter
      self.to_user_id = self.booking.from_user_id
    end
  end
end