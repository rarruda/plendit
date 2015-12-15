class MessageDecorator < Draper::Decorator
  delegate_all
  decorates_association :to_user
  decorates_association :from_user
  decorates_association :booking

  def activity_message current_user
    if current_user == self.from_user
      "Du sendte en melding til #{self.to_user.display_name}"
    else
      "Du har mottatt en melding fra #{self.from_user.display_name}"
    end
  end

end
