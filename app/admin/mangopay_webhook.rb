ActiveAdmin.register MangopayWebhook do

  menu priority: 10
  actions :index, :show

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :event_type_mp
    column :resource_type
    column :resource_vid
    column :date_mp
    column :status
    column :remote_ip
    column :raw_data

    column :created_at
    actions
  end

end