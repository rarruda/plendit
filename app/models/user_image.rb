class UserImage < ActiveRecord::Base
  belongs_to :user

  enum category: { avatar: 0, logo: 1 }

  scope :avatar, -> { where( category: 'avatar') }

  has_attached_file :image, {
    styles: {
      avatar_huge: "120x120>",
      avatar_medium: "64x64>"
    },
    default_url:    nil,
    path:           "/images/users/:user_id/:style/:hash.:extension",
    preserve_files: false, #true for Soft-delete (delete only from database, not from storage/s3)
    hash_data:      ":class/:attachment/:id",
    hash_secret:    ENV['PCONF_PAPERCLIP_HASH_SALT'],
  }

  validates_attachment_content_type :image, content_type: ["image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :image, matches: [/png\Z/i, /jpe?g\Z/i]
  validates_attachment_size         :image, in: 0..4.megabytes
end
