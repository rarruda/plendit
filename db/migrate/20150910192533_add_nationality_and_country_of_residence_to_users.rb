class AddNationalityAndCountryOfResidenceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nationality, :string, limit: 2
    add_column :users, :country_of_residence, :string, limit: 2
  end
end
