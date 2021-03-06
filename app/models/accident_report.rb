class AccidentReport < ActiveRecord::Base

  has_paper_trail

  belongs_to :booking
  belongs_to :from_user, class_name: "User"

  has_many :accident_report_attachments, dependent: :destroy

  accepts_nested_attributes_for :accident_report_attachments, reject_if: :all_blank

  after_create :email_notification_to_customer_service

  validates :body,          presence: true #, message: "Du må fylle ut en beskrivelse av hva som har skjedd." }
  validates :location_line, presence: true

  attr_accessor :attachments

  def booking_guid
    self.booking_id.present? ? self.booking.guid : ''
  end

  def attachments=(attachments)
    attachments.each do |a|
      accident_report_attachments.build(attachment: a)
    end
  end

  private
  def email_notification_to_customer_service
    ApplicationMailer.accident_report_created__to_customer_service( self ).deliver_later
  end
end
