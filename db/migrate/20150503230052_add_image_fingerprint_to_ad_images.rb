class AddImageFingerprintToAdImages < ActiveRecord::Migration
  def change
    add_column :ad_images, :image_fingerprint, :string
  end
end
