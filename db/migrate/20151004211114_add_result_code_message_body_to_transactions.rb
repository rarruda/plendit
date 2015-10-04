class AddResultCodeMessageBodyToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :result_code, :string
    add_column :transactions, :result_message, :string
    add_column :transactions, :response_body, :text
  end
end
