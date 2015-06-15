class AddDefaultUserStatus < ActiveRecord::Migration
  def change
    change_column :users, :status, :integer, :default => 1
  end
end
