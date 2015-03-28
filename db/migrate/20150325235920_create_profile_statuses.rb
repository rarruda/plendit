class CreateProfileStatuses < ActiveRecord::Migration
  def change
    create_table :profile_statuses do |t|
      t.string :status

      t.timestamps null: false
    end
  end
end
