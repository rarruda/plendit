ActiveAdmin.register MangopayWebhook do

  menu priority: 10
  actions :index, :show

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :event_type
    column :resource_type
    column :resource_vid
    column :timestamp_v
    column(:status)   {|ad| status_tag(ad.status) }
    column :remote_ip
    column :raw_data

    column :created_at
    actions
  end

end