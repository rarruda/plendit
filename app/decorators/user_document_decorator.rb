class UserDocumentDecorator < Draper::Decorator
  delegate_all
  decorates_association :user

  def display_category
    names = {
     unknown: 'Ukjent',
     drivers_license_front: 'Førerkort',
     drivers_license_back: 'Førerkort (bakside)',
     boat_license: 'Båtførerbevis',
     passport: 'Pass',
     id_card: 'ID-kort',
     other: 'Annet'
   }
   names[category.to_sym]
  end

end
