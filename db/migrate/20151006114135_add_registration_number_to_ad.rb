class AddRegistrationNumberToAd < ActiveRecord::Migration
  def change
    add_column :ads, :registration_number, :string
  end
end
