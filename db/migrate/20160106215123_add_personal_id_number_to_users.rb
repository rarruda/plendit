class AddPersonalIdNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :personal_id_number, :string
    add_index :users, :personal_id_number, unique: true
  end
end
