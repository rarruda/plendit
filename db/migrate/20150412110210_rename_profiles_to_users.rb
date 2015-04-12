class RenameProfilesToUsers < ActiveRecord::Migration
  def change
    rename_table  :profile_statuses, :user_statuses
    rename_column :profiles, :profile_status_id, :user_status_id

    rename_table :profiles, :users

    rename_column :ads,       :profile_id,      :user_id
    rename_column :bookings,  :from_profile_id, :from_user_id
    rename_column :feedbacks, :from_profile_id, :from_user_id
    rename_column :messages,  :from_profile_id, :from_user_id
    rename_column :messages,  :to_profile_id,   :to_user_id
  end
end
