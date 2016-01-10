class AddPublicNameToUser < ActiveRecord::Migration
  def up
    add_column :users, :public_name, :string
    execute "UPDATE users SET public_name = first_name"
  end
  def down
    remove_column :users, :public_name
  end
end
