class AddBoatFieldsToAd < ActiveRecord::Migration
  def change
    add_column :ads, :estimated_value, :integer
    add_column :ads, :boat_license_required, :boolean
  end
end
