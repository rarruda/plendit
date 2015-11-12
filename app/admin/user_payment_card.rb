ActiveAdmin.register UserPaymentCard do

  menu :priority => 6
  #actions :index, :show
  actions :index

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :user_id
    column :active
    column :card_provider
    column :card_type
    column :card_vid
    column :payin_wallet_vid
    column :number_alias
    column :expiration_date
    column :validity
    column :guid

    column :created_at
    actions
  end

end
