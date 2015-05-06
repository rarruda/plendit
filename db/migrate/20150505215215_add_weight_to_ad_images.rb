class AddWeightToAdImages < ActiveRecord::Migration
  def change
    add_column :ad_images, :weight, :integer
  end
end
