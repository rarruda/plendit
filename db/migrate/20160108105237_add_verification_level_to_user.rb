class AddVerificationLevelToUser < ActiveRecord::Migration
  def change
    add_column :users, :verification_level, :integer, default: 0
  end
end
