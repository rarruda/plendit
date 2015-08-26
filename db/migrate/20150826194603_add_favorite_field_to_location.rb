class AddFavoriteFieldToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :favorite, :boolean, :default => false
  end
end
