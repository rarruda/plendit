class AddBirthdayFirstLastNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :birthday, :date
    add_column :users, :last_name, :string
    rename_column :users, :display_name, :first_name
  end
end
