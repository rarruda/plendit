class AddAdItemsForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :ad_items, :ads
  end
end
