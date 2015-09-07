class RenameCategoryToPersonhoodForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :category, :personhood
  end
end
