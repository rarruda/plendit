class RenameAvatarUrlInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :avatar_url, :image_url
  end
end
