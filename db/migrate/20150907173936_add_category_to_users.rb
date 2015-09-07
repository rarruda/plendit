class AddCategoryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :category, :integer
  end
end
