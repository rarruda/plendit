ActiveAdmin.register Location do


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

  menu priority: 5
  #actions :index, :show

  permit_params :user_id, :address_line, :post_code

  controller do
    defaults finder: :find_by_guid
  end

  index do
    selectable_column
    id_column
    column :user
    column :favorite
    column :address_line
    column :city
    column :state
    column :post_code
    column :lat
    column :lon
    column :geo_precision
    column :status

    column :created_at
    actions
  end

end
