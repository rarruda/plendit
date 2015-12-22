class AddGuidToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :guid, :string, limit: 36
    add_index :locations, :guid, unique: true

    execute "UPDATE locations SET guid = id WHERE guid IS NULL;"
  end

  def down
    remove_column :locations, :guid
  end
end
