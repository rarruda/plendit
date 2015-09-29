class AdImage < ActiveRecord::Base
  belongs_to :ad

  default_scope { order('weight, id') }

  DIMENSIONS = {
    thumb:        { width: 180,  height: 120 },
    searchresult: { width: 450,  height: 300 },
    hero:         { width: 900,  height: 600 },
    gallery:      { width: 1600, height: nil }
  }

  has_attached_file :image, {
    :styles      => {
      :thumb        => "#{DIMENSIONS[:thumb][:width]}x#{DIMENSIONS[:thumb][:height]}#",
      :searchresult => "#{DIMENSIONS[:searchresult][:width]}x#{DIMENSIONS[:searchresult][:height]}#",
      :hero         => "#{DIMENSIONS[:hero][:width]}x#{DIMENSIONS[:hero][:height]}#",
      :gallery      => "#{DIMENSIONS[:gallery][:width]}"
    },
    :default_url => "/images/:style/missing.png",
    :path        => "/images/ads/:ad_id/:style/:hash.:extension",
    :hash_data   => ":class/:attachment/:id",
    :hash_secret => ENV['PCONF_PAPERCLIP_HASH_SALT'],
  }

  scope :for_ad_id, ->(ad_id) { where( ad_id: ad_id ) }


  validates :weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :image, :matches => [/png\Z/, /jpe?g\Z/]
  validates_attachment_size         :image, :in => 0..10.megabytes

  def self.imageSize(style)
    "#{DIMENSIONS[style][:width]}x#{DIMENSIONS[style][:height]}"
  end

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

  def make_primary
    AdImage.transaction do
      self.update(weight: 1)
      self.ad.ad_images.order(:weight).where.not(id: self.id).each_with_index do |img, index|
        img.update(weight: index + 2)
      end
    end
  end

end
