class AddSemanshipFlag < ActiveRecord::Migration
  def change
    add_column :users, :seamanship_confirmed, :boolean, default: false
  end
end
