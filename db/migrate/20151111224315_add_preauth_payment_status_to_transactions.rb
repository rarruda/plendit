class AddPreauthPaymentStatusToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :preauth_payment_status, :integer, default: 0
  end
end
