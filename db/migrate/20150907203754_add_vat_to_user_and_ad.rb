class AddVatToUserAndAd < ActiveRecord::Migration
  def change
    add_column :users, :pays_vat, :bool
    add_column :ads,   :requires_vat, :bool
  end
end