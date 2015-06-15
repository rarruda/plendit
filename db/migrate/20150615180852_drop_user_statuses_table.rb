class DropUserStatusesTable < ActiveRecord::Migration
  def up
    drop_table :user_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
