class AddAuthInfoToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :email, :string
    add_index :profiles, :email
    add_column :profiles, :password_digest, :string
  end
end
