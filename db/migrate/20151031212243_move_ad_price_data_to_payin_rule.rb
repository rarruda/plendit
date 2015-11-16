class MoveAdPriceDataToPayinRule < ActiveRecord::Migration
  def up
    execute "DELETE FROM payin_rules;"
    execute "INSERT INTO payin_rules ( ad_id, payin_amount, effective_from, unit ) SELECT a.id, a.amount, 1, 2 FROM ads AS a;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
