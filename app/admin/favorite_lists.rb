ActiveAdmin.register FavoriteList do


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

  menu :priority => 6
  #actions :index, :show

  permit_params :name

  index do
    selectable_column
    id_column
    column :user
    column :name

    column :created_at
    actions
  end


end
