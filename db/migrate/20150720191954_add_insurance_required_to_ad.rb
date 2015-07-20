class AddInsuranceRequiredToAd < ActiveRecord::Migration
  def change
    add_column :ads, :insurance_required, :integer
  end
end
