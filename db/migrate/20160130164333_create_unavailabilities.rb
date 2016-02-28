class CreateUnavailabilities < ActiveRecord::Migration
  def change
    create_table :unavailabilities do |t|
      t.date :from_date
      t.date :to_date
      t.references :ad, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
