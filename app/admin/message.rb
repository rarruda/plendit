ActiveAdmin.register Message do


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
  actions :index, :show


  #permit_params :ad_item_id, :from_user_id

  index do
    selectable_column
    id_column
    #column :ad_item_id
    #column :ad
    column('Ad ID') {|m| link_to "#{m.booking.ad.id}", admin_ad_path(m.booking.ad.id) }
    column('Ad Title') {|m| link_to "#{m.booking.ad.title}", admin_ad_path(m.booking.ad.id) }
    column :from_user
    column :to_user
    column :booking
    #column('Booking Status') {|b| status_tag b.booking_status.status}
    column :content
    column :created_at
    actions
  end

end
