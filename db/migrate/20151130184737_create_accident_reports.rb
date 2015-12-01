class CreateAccidentReports < ActiveRecord::Migration
  def change
    create_table :accident_reports do |t|
      t.references :booking
      t.references :from_user
      t.datetime :happened_at
      t.string :location_address_line
      t.string :location_post_code
      t.string :location_city
      t.string :location_state
      t.string :location_country, limit: 2
      t.text :body

      t.timestamps null: false
    end
  end
end
