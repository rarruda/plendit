class RenameSeamanshipFlag < ActiveRecord::Migration
  def change
    rename_column :users, :seamanship_confirmed, :seamanship_claimed
  end
end
