class BookingDecorator < Draper::Decorator
  delegate_all
  decorates_association :ad
  decorates_association :user
  decorates_association :from_user
  decorates_association :messages
end
