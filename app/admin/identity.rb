ActiveAdmin.register Identity do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  menu priority: 6

  permit_params :image_url, :profile_url

  index do
    selectable_column
    id_column
    column :user
    column :provider
    column :uid
    column :email
    column :image_url
    column :profile_url
  end

end
