class AddProfileStatusToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :profile_status_id, :integer
    add_index :profiles, :profile_status_id
  end
end
