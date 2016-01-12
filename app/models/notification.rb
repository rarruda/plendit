class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  enum status: [ :fresh, :noticed, :read ]

  scope :fresh, -> { where( status: Notification.statuses[:fresh] ) }


  def source_user
    if self.notifiable.is_a? Ad
      self.notifiable.user
    elsif self.notifiable.is_a? Message
      self.notifiable.from_user
    elsif self.notifiable.is_a? Booking
      if self.user == self.notifiable.from_user
        self.notifiable.user
      else
        self.notifiable.from_user
      end
    else
      self.user
    end
  end

  def source_path
    # todo: implement all
    if self.notifiable.is_a? Ad
      Rails.application.routes.url_helpers.ad_path self.notifiable.id
    elsif notifiable.is_a? Booking
      Rails.application.routes.url_helpers.booking_path self.notifiable.guid
    elsif notifiable.is_a? UserDocument
      Rails.application.routes.url_helpers.users_path
    else
      "/"
    end
  end

end
