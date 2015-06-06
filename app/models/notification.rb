class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  def source_user
    if self.notifiable is_a? Ad
        self.notifiable.user
    elsif self.notifiable is_a? Message
        self.notifiable.from_user
    elsif self.notifiable is_a? Booking
        # todo: this depends on if you're renter og rentee
        self.notifiable.from_user
    else
        self.user
    end
  end
end
