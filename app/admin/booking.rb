ActiveAdmin.register Booking do


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


  #permit_params :ad_item_id, :from_user_id

  index do
    selectable_column
    id_column
    column :ad_item_id
    column :ad
    column :user
    column :from_user
    #column :booking_status
    column('Booking Status') {|b| status_tag b.booking_status.status}
    column :created_at
    actions
  end

end
