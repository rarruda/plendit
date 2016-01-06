class RemoveIrrelevantAddressInfoFromAccidentReport < ActiveRecord::Migration
  def change
    rename_column :accident_reports, :location_address_line, :location_line
    remove_column :accident_reports, :location_post_code
    remove_column :accident_reports, :location_city
    remove_column :accident_reports, :location_state
    remove_column :accident_reports, :location_country
  end
end
