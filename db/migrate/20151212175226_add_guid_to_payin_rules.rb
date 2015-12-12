class AddGuidToPayinRules < ActiveRecord::Migration
  def change
    add_column :payin_rules, :guid, :string, limit: 36
    add_index :payin_rules, :guid, unique: true

    execute "UPDATE payin_rules SET guid = id WHERE guid IS NULL;"
  end
end
