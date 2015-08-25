class AddAdsForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :ads, :users
  end
end
