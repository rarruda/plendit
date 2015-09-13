class MessageDecorator < Draper::Decorator
  delegate_all
  decorates_association :to_user
  decorates_association :from_user
  decorates_association :booking
end
