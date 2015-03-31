class ProfilePhomenumberToPhonenumber < ActiveRecord::Migration
  def change
    rename_column :profiles, :phome_number, :phone_number
  end
end
