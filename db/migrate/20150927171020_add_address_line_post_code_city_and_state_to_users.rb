class AddAddressLinePostCodeCityAndStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :home_address_line, :string
    add_column :users, :home_post_code, :string
    add_column :users, :home_city, :string
    add_column :users, :home_state, :string
  end
end
