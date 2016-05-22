class AddDateToWantedItem < ActiveRecord::Migration
  def change
    add_column :wanted_item_requests, :when, :string
  end
end
