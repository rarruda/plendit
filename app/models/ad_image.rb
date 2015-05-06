class AdImage < ActiveRecord::Base
  belongs_to :ad

  default_scope { order('weight') }

  has_attached_file :image, {
    :styles => { :mediumplus => "540x540>", :medium => "320x320>", :thumb => "120x120>" },
    :url => "/system/:style/:hash.:extension", #### "/system/ad_image/:ad_id/:style/:hash.:extension"
    :hash_data => ":class/:attachment/:id", #:hash_data => ":class/:attachment/:id/:style/:updated_at"
    :hash_secret => "longSuperDuperSecretSaltStringForObfuscation",
    :default_url => "/images/:style/missing.png"
  }

  validates :weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/jpg", "image/png"]
  #/\Aimage/
  validates_attachment_file_name    :image, :matches => [/png\Z/, /jpe?g\Z/]

end
