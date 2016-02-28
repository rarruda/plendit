ActiveAdmin.register Feedback do


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
  actions :index, :show


  permit_params :booking_id, :from_user_id, :score, :body

  index do
    selectable_column
    id_column
    column :booking
    column :from_user
    column :user
    column :score
    column :created_at
    actions
  end


end
