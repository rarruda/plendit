class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|

      t.timestamps null: false
    end
  end
end
