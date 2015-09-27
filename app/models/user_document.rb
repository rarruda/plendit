class UserDocument < ActiveRecord::Base
  belongs_to :user

  has_paper_trail

  has_attached_file :document, {
    #:styles      => { thumbnail: "200x200>" }
    :hash_data   => ":class/:attachment/:id",
    :hash_secret => "longSuperDuperSecretSaltStringForObfuscation__BUT_notTheSameAsAnyOtherModelThatWeUse", #ENV['PCONF_PAPERCLIP_HASH_SALT_DOCUMENTS']
    :default_url => nil,
    :preserve_files => true, #true for Soft-delete (delete only from database, not from storage/s3)
    :url         => ":s3_domain_url",
    :path        => "/images/users/:user_id/:style/:hash.:extension",
    #:bucket     => 'secure_document_bucket',
  }

  enum category: { unknown: 0, drivers_license: 1, passport: 2, id_card: 3, other: 5 }

  validates_attachment_content_type :image, :content_type => ["application/pdf", "image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :image, :matches => [/png\Z/, /jpe?g\Z/, /pdf\Z/]
  validates_attachment_size         :image, :in => 0..8.megabytes

  validates_uniqueness_of :guid


  before_validation :set_guid, :on => :create



  def to_param
    self.guid
  end

  private

  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
