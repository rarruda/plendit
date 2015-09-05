class UserImage < ActiveRecord::Base
  belongs_to :user

  enum type: { avatar: 0, logo: 1 }

  has_attached_file :image, styles: { avatar_huge: "120x120>", avatar_medium: "64x64>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

end
