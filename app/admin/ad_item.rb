ActiveAdmin.register AdItem do


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

  permit_params :ad_id #, :ad_item_id

  index do
    selectable_column
    id_column
    column("Ad ID")    { |ai| link_to "#{ai.ad_id} ", admin_ad_path(ai.ad_id) }
    column("Ad Title") { |ai| link_to "#{ai.ad.title} ", admin_ad_path(ai.ad_id) }
    column :created_at
    actions
  end


end
