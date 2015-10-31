class RenameAmountToPayinAmountAndEffectiveFromUnitToEffectiveFromInPriceRule < ActiveRecord::Migration
  def change
    rename_column :price_rules, :amount, :payin_amount
    rename_column :price_rules, :effective_from_unit, :effective_from
  end
end
