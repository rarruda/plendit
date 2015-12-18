class AddRefusalReasonToAds < ActiveRecord::Migration
  def change
    add_column :ads, :refusal_reason, :string
  end
end
