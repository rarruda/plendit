class RemoveInsuranceRequiredFromAd < ActiveRecord::Migration
  def change
    remove_column :ads, :insurance_required, :boolean
  end
end
