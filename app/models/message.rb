class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :from_user,     class_name: "User"
  belongs_to :to_user,       class_name: "User"
  has_many   :notifications, as: :notifiable, dependent: :destroy

  validates  :content, length: { in: 2..8192 }

  #after_validate :update_first_reply_at, on: :create
  #def update_first_reply_at
  #   update_attribute???
  #  self.booking.first_reply_at ||= self.created_at
  #end

  after_save :email_message

  private
  def email_message
    ApplicationMailer.message__to_user( self ).deliver_later
  end
end
