class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :ads
  decorates_association :current_bookings
  decorates_association :bookings
  decorates_association :sent_bookings
  decorates_association :received_messages

  def display_name
    self.first_name.blank? ? "Navn mangler" : self.first_name
    #( self.personhood == :natural ) ? ( self.first_name.blank? ? self.name : self.first_name ) : self.name
  end

  def published_ads
    object.ads.published.decorate
  end

  def current_phone_number
    object.unconfirmed_phone_number || object.phone_number
  end

end
