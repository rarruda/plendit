class BookingDecorator < Draper::Decorator
  delegate_all
  decorates_association :ad
  decorates_association :user
  decorates_association :from_user
  decorates_association :messages

  # need decorator for sum_paid_to_owner, sum_paid_by_renter
end
