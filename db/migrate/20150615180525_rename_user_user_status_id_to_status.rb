class RenameUserUserStatusIdToStatus < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :user_status_id, :status
    end
  end
end
