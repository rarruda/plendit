class AddNatureToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :nature, :integer, default: 0
  end
end
