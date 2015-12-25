class AccidentReport < ActiveRecord::Base

  has_paper_trail

  belongs_to :booking
  belongs_to :from_user, :class_name => "User"

  validates :body,                  presence: true #, message: "Du må fylle ut en beskrivelse av hva skjedd." }
  validates :location_address_line, presence: true
  #validates :location_city,         presence: true
  validates :location_post_code,    presence: true, format: { with: /\A[0-9]{4,8}\z/, message: "må være kun tall. 4-8 siffer." }


  def booking_guid
    self.booking_id.present? ? self.booking.guid : ''
  end
end
