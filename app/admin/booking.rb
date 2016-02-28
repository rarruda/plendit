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

  menu priority: 3
  actions :index, :show

  #permit_params :ad_item_id, :from_user_id

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
    column :payout_amount
    column(:status) {|ad| status_tag(ad.status) }
    column :created_at
    actions
  end

  controller do
    def show
        @booking  = Booking.includes(versions: :item).find_by_guid(params[:id])
        @versions = @booking.versions
        @booking  = @booking.versions[params[:version].to_i].reify if params[:version]
        show! #it seems to need this

#    @booking = Booking.find_by_guid(params[:id])
#    @versions = @booking.versions
    end
  end
  sidebar :versionate,  partial: "admin/version", only: :show
  sidebar :history,     partial: "admin/history", only: :show #layout: false

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
