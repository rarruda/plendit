ActiveAdmin.register Ad do


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

  menu :priority => 4
  #actions :index, :show

  permit_params :title, :price, :tags, :body, :location_id #, :user_id

  index do
    selectable_column
    id_column
    column :title
    column :price
    column :tags
    #column :body

    column("Owner") { |ad| link_to "#{ad.user.safe_display_name}", admin_user_path( ad.user.id ) }

    column :created_at
    actions
  end

end
