ActiveAdmin.register AccidentReport do

  menu priority: 6
  actions :index, :show

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :booking_id
    column :from_user_id
    column :happened_at
    #column :location_address_line
    column :location_post_code
    #column :location_country
    column :body

    column :created_at
    actions
  end

end