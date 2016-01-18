ActiveAdmin.register FinancialTransaction do

  menu priority: 8
  actions :index, :show

  #permit_params :user_id, :foobar

  controller do
    defaults finder: :find_by_guid
  end

  index do
    selectable_column
    id_column
    column :guid
    column :src_vid
    column :src_type
    column :dst_vid
    column :dst_type
    column(:transaction_type)   {|t| status_tag(t.transaction_type) }
    column :transaction_vid
    column(:state)              {|t| status_tag(t.state) }
    column :amount
    column :fees
    column :financial_transactionable_type
    column :financial_transactionable_id

    column :created_at
    actions
  end

  controller do
    def show
        @financial_transactions  = FinancialTransaction.includes(versions: :item).find_by_guid(params[:id])
        @versions                = @financial_transactions.versions
        @financial_transactions  = @financial_transactions.versions[params[:version].to_i].reify if params[:version]
        show! #it seems to need this
    end
  end
  sidebar :versionate, :partial => "admin/version", only: :show

end
