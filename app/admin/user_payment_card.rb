ActiveAdmin.register UserPaymentCard do

  menu :priority => 6
  #actions :index, :show
  actions :index

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :user_id
    column :active_mp
    column :card_type
    column :card_vid
    column :payin_wallet_vid
    column :expiration_date
    column :last_known_status_mp
    column :guid
    column :number_alias
    column :validity_mp

    column :created_at
    actions
  end

end
