class AddBoatInsuranceAcceptanceField < ActiveRecord::Migration
  def change
    add_column :ads, :accepted_boat_insurance_terms, :boolean, default: false
  end
end
