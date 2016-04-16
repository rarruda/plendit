class AddVerificationLevelToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :verification_level, :integer
  end
end
