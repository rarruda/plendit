class RenameDateFieldsInUnavailability < ActiveRecord::Migration
  def change
    rename_column :unavailabilities, :from_date, :starts_at
    rename_column :unavailabilities, :to_date, :ends_at
  end
end
