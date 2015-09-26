class AddGeoPrecisionToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :geo_precision, :integer
    add_column :locations, :geo_precision_type, :string
  end
end
