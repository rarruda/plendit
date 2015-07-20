class AddNameAndEmailsToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :email, :string
    add_column :identities, :name, :string
    add_column :identities, :first_name, :string
    add_column :identities, :last_name, :string
    add_column :identities, :nickname, :string
  end
end
