class RenameUserImageTypeToCategory < ActiveRecord::Migration
  def change
    rename_column :user_images, :type, :category
  end
end
