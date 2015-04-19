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

  menu :priority => 5
  #actions :index, :show

  permit_params :address_line, :city, :state, :post_code, :lat, :lon

  index do
    selectable_column
    id_column
    column :address_line
    column :city
    column :state
    column :post_code
    column :lat
    column :lon

    column :created_at
    actions
  end

end
