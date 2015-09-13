class UserDecorator < Draper::Decorator
  delegate_all

  def display_name
    self.first_name
    #( self.personhood == :natural ) ? ( self.first_name.blank? ? self.name : self.first_name ) : self.name
  end

end
