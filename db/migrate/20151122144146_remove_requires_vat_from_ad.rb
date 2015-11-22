class RemoveRequiresVatFromAd < ActiveRecord::Migration
  def change
    remove_column :ads, :requires_vat, :boolean
  end
end
