class ChangeInsuranceRequiredToBoolInAds < ActiveRecord::Migration
  def change
    change_column :ads, :insurance_required, 'boolean USING CAST(insurance_required AS boolean)'
  end
end
