class FeedbackDecorator < Draper::Decorator
  delegate_all
  decorates_association :user
  decorates_association :from_user
  decorates_association :ad
end
