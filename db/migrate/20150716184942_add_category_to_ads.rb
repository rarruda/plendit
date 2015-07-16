class AddCategoryToAds < ActiveRecord::Migration
  def change
    add_column :ads, :category, :integer, :default => 0
  end
end
