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

  enum category: { unknown: 0, drivers_license_front: 1, drivers_license_back: 2, boat_license: 3, passport: 4, id_card: 5, other: 10 }
  enum status:   { not_approved: 1, pending_approval: 2, approved: 3 }
  # status: pending_approval 2=>1(pending_approval=>waiting_approval), approved: 3=>5, not_approved: 1=>10

  validates_attachment_content_type :document, :content_type => ["application/pdf", "image/jpeg", "image/jpg", "image/png"]
  validates_attachment_file_name    :document, :matches => [/png\Z/i, /jpe?g\Z/i, /pdf\Z/i]
  validates_attachment_size         :document, :in => 0..10.megabytes

  validates_uniqueness_of :guid

  validates_uniqueness_of :user_id, scope: :category


  scope :pending_approval,  -> { where( status: UserDocument.statuses[:pending_approval] ) }
  scope :not_approved,      -> { where( status: UserDocument.statuses[:not_approved] ) }
  scope :approved,          -> { where( status: UserDocument.statuses[:approved] ) }


  before_validation :set_guid, on: :create



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
