class UserDocumentDecorator < Draper::Decorator
  delegate_all
  decorates_association :user

  def display_category
    names = {
     unknown: 'dnknown',
     drivers_license_front: 'driver\'s license (front)',
     drivers_license_back: 'driver\'s license (back)',
     boat_license: 'boat license',
     passport: 'passport',
     id_card: 'ID card',
     other: 'other'
   }
   names[category.to_sym]
  end

end
