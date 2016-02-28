class Unavailability < ActiveRecord::Base
  belongs_to :ad

  default_scope { where('ends_at >= ?', Date.today).order('starts_at') }

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_at_after_starts_at

  private

  def ends_at_after_starts_at
    if ends_at < starts_at
      self.errors.add(:ends_at, 'Til-dato må være etter fra-dato')
    end
  end

end
