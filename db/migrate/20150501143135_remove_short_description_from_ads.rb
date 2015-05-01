class RemoveShortDescriptionFromAds < ActiveRecord::Migration
  def change
    remove_column :ads, :short_description, :text
  end
end
