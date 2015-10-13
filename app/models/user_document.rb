class UserDocument < ActiveRecord::Base
  belongs_to :user

  has_paper_trail

  has_attached_file :document, {
    #:styles        => { thumbnail: "200x200>" }
    # https://github.com/thoughtbot/paperclip#uri-obfuscation
    :path           => "/documents/users/:user_id/:hash.:extension", # :filename
    :preserve_files => true, #true for Soft-delete (delete only from database, not from storage/s3)
    :hash_data      => ":class/:attachment/:id",
    :hash_secret    => ENV['PCONF_DOCUMENTS_PAPERCLIP_HASH_SALT'],
    :default_url    => nil,
    :url            => ":s3_domain_url",
    :s3_host_alias  => nil,
    :s3_permissions => :private,
    :s3_credentials => {
      :bucket            => ENV['PCONF_DOCUMENTS_S3_BUCKET_NAME'],
      :access_key_id     => ENV['PCONF_DOCUMENTS_AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['PCONF_DOCUMENTS_AWS_SECRET_ACCESS_KEY']
    },
  }

  enum category: { unknown: 0, drivers_license: 1, passport: 2, id_card: 3, other: 5 }

  validates_attachment_content_type :document, :content_type => ["application/pdf", "image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :document, :matches => [/png\Z/i, /jpe?g\Z/i, /pdf\Z/i]
  validates_attachment_size         :document, :in => 0..10.megabytes

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
