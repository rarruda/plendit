class Unavailability < ActiveRecord::Base
  belongs_to :ad

  validates :from_date, presence: true,
  validates :to_date, presence: true,
  validate :to_date_after_from_date

  private

  def to_date_after_from_date
    if to_date < from_date
      self.errors.add(:to_date, 'Til-dato må være etter fra-dato')
    end
  end

end
