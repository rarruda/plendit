class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :ads
  decorates_association :current_bookings
  decorates_association :bookings
  decorates_association :sent_bookings
  decorates_association :received_messages
  decorates_association :received_feedbacks
  decorates_association :recent_feedback
  decorates_association :user_documents

  def display_name
    self.public_name.blank? ? 'Navn mangler' : self.public_name
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

  def display_about
    joined_year = self.created_at.year
    self.about || "#{self.display_name} har vært bruker på Plendit siden #{joined_year}."
  end

  def published_ads
    object.ads.published.decorate
  end

end
