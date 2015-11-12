class RenameStatusMpToStateInTransactions < ActiveRecord::Migration
  def change
    rename_column :transactions, :status_mp, :state
  end
end
