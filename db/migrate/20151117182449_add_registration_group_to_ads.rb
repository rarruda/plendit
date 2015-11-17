class AddRegistrationGroupToAds < ActiveRecord::Migration
  def change
    add_column :ads, :registration_group, :integer
  end
end
