class BookingDecorator < Draper::Decorator
  delegate_all
  decorates_association :ad
end
