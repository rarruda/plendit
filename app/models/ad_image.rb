class AdImage < ActiveRecord::Base
  belongs_to :ad

  default_scope { order('weight, id') }

  has_attached_file :image, {
    :styles      => { 
      :thumb => "180x120#",
      :searchresult => "450x300#",
      :hero => "900x600#",
      :gallery => "1600"
    },
    :convert_options => { :thumb => "-quality 75 -strip" },
    :hash_data   => ":class/:attachment/:id",
    :hash_secret => "longSuperDuperSecretSaltStringForObfuscation", #ENV['PCONF_PAPERCLIP_HASH_SALT']
    :default_url => "/images/:style/missing.png",
    #:preserve_files => "true", #Soft-delete (delete only from database, not from storage/s3)
    :url         => ":s3_domain_url",
    :path        => "/images/ads/:ad_id/:style/:hash.:extension", #### "/system/ad_image/:ad_id/:style/:hash.:extension"
  }

  scope :for_ad_id, ->(ad_id) { where( ad_id: ad_id ) }


  validates :weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :image, :matches => [/png\Z/, /jpe?g\Z/]




  include Rails.application.routes.url_helpers

  def to_dropzone_gallery
    {
      "name" => read_attribute(:image_file_name),
      "size" => read_attribute(:image_file_size),
      "type" => read_attribute(:image_content_type),
      "url" => image.url(:thumb),
      "ad_image_id" => self.id,
      "delete_url" => ad_image_path(:ad_id => ad_id, :id => id, :format => :json),
      ##"delete_type" => "DELETE" 
    }
  end

end
