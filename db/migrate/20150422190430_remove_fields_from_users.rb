class RemoveFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :private_link_to_facebook, :string
    remove_column :users, :private_link_to_linkedin, :string
    remove_column :users, :join_timestamp, :timestamp
    remove_column :users, :last_action_timestamp, :timestamp
  end
end
