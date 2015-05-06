class AddAttachmentImageToAdImages < ActiveRecord::Migration
  def self.up
    change_table :ad_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :ad_images, :image
  end
end
