class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :ads
  decorates_association :current_bookings
  decorates_association :bookings
  decorates_association :sent_bookings
  decorates_association :received_messages
  decorates_association :received_feedbacks
  decorates_association :recent_feedback

  def display_name
    self.first_name.blank? ? 'Navn mangler' : self.first_name
    #( self.personhood == :natural ) ? ( self.first_name.blank? ? self.name : self.first_name ) : self.name
  end

  def display_full_name
    "#{self.first_name || '(fornavn mangler)'} #{self.last_name || '(etternavn mangler)'}"
  end

  def display_email
    self.email_verified? ? self.email : 'E-post ikke verifisert'
  end

  def display_name_posessive
    name = self.display_name
    name[-1] == 's' ? "#{name}'" + '\'' : "#{name}s"
  end

  def published_ads
    object.ads.published.decorate
  end

end
