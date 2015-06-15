class DropBookingStatusesTable < ActiveRecord::Migration
  def up
    drop_table :booking_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
