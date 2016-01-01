class MoveAdPriceDataToPayinRule < ActiveRecord::Migration
  def up
    execute "DELETE FROM payin_rules;"
    execute <<-SQL
      INSERT INTO payin_rules ( ad_id, payin_amount, effective_from, unit, created_at, updated_at )
        SELECT a.id, a.price, 1, 2, current_timestamp, current_timestamp FROM ads AS a;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
