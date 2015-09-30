ActiveAdmin.register UserPaymentAccount do

  menu :priority => 6
  #actions :index, :show
  actions :index

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :user_id
    column :bank_account_iban
    column :bank_account_number
    column :bank_account_vid
    column :payin_wallet_vid
    column :payout_wallet_vid

    column :created_at
    actions
  end

end