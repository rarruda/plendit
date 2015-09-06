class UserImage < ActiveRecord::Base
  belongs_to :user

  enum category: { avatar: 0, logo: 1 }

  scope :avatar, -> { where( category: 'avatar') }

  has_attached_file :image, {
    :styles      => {
      avatar_huge: "120x120>",
      avatar_medium: "64x64>"
    },
##      :thumb => "#{DIMENSIONS[:thumb][:width]}x#{DIMENSIONS[:thumb][:height]}#",
##      :searchresult => "#{DIMENSIONS[:searchresult][:width]}x#{DIMENSIONS[:searchresult][:height]}#",
##      :hero => "#{DIMENSIONS[:hero][:width]}x#{DIMENSIONS[:hero][:height]}#",
##      :gallery => "#{DIMENSIONS[:gallery][:width]}"
##    },
    :hash_data   => ":class/:attachment/:id",
    :hash_secret => "longSuperDuperSecretSaltStringForObfuscation", #ENV['PCONF_PAPERCLIP_HASH_SALT']
    :default_url => nil,
    :preserve_files => "false", #true for Soft-delete (delete only from database, not from storage/s3)
    :url         => ":s3_domain_url",
    :path        => "/images/users/:user_id/:style/:hash.:extension",
  }

  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :image, :matches => [/png\Z/, /jpe?g\Z/]
  validates_attachment_size         :image, :in => 0..2.megabytes

end
