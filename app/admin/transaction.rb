ActiveAdmin.register Transaction do

  menu :priority => 8
  #actions :index, :show
  actions :index, :show

  #permit_params :user_id, :foobar

  index do
    selectable_column
    id_column
    column :guid
    column :src_vid
    column :src_type
    column :dst_vid
    column :dst_type
    column :transaction_vid
    #column :transaction_type
    column(:transaction_type)   {|t| status_tag(t.transaction_type) }
    column(:state)              {|t| status_tag(t.state) }
    column :amount
    column :fees
    column :transactionable_type
    column :transactionable_id

    column :created_at
    actions
  end

end
