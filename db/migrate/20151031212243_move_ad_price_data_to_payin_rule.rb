class MoveAdPriceDataToPayinRule < ActiveRecord::Migration
  def up
    Ad.unscoped.all.each do |a|
      pi = a.payin_rules.find_or_initialize_by(unit: PayinRule.units[:day], effective_from: 1)

      pi.update_column( :payin_amount, a.price ) if pi.new_record?
      a.update_column( :price, nil )

      pi.save!(:validate => false)
      a.save!(:validate => false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
