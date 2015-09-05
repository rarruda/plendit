class AddAttachmentImageToUserImages < ActiveRecord::Migration
  def self.up
    change_table :user_images do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :user_images, :image
  end
end
