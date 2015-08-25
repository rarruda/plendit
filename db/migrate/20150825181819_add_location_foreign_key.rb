class AddLocationForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :locations, :users
  end
end
