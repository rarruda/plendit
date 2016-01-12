class UserPaymentCardDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def pretty_view
    "#{self.pretty_number_alias} -- #{pretty_expiration_date}"
  end

  def pretty_number_alias
    object.number_alias.scan(/.{4}/).join(' ').html_safe
  end

  def pretty_expiration_date
    object.expiration_date.scan(/.{2}/).join("/")
  end

  def validity_icon_name
    if object.pending?
      'hourglass-start'
    elsif object.processing?
      'hourglass-half'
    elsif object.card_valid?
      'check'
    elsif object.card_invalid?
      'times'
    elsif object.errored?
      'times'
    else
      'question'
    end
  end

end
