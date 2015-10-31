class RenamePriceRuleToPayinRule < ActiveRecord::Migration
  def change
    rename_table :price_rules, :payin_rules
  end
end
