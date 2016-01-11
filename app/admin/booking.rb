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

  menu priority: 5
  #actions :index, :show

  permit_params :ad_item_id, :from_user_id, :amount, :status

  controller do
    defaults finder: :find_by_guid
  end

  index do
    selectable_column
    id_column
    column :ad_item
    column :ad
    column :user
    column :from_user
    column :amount
    column :status
    column :created_at
    actions
  end

  member_action :history do
    @booking = Booking.find_by_guid(params[:id])
    @versions = @booking.versions
    render "admin/history", layout: false
    # https://github.com/activeadmin/activeadmin/wiki/Auditing-via-paper_trail-(change-history)
    # https://github.com/activeadmin/activeadmin/issues/827
    # looks like another gem has registered a method in the same namespace, so activeadmin can't
    #  render the page.
  end

end
