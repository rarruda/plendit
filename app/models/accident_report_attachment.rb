class AccidentReportAttachment < ActiveRecord::Base

  belongs_to :accident_report

  has_attached_file :attachment, {
    path:            "/documents/accident_reports/:accident_report_id/:hash.:extension",
    preserve_files:  false, #true for Soft-delete (delete only from database, not from storage/s3)
    hash_data:       ":class/:attachment/:id",
    hash_secret:     ENV['PCONF_DOCUMENTS_PAPERCLIP_HASH_SALT'],
    default_url:     nil,
    url:             ":s3_domain_url",
    s3_host_alias:   nil,
    s3_permissions:  :private,
    s3_credentials:  {
      bucket:             ENV['PCONF_DOCUMENTS_S3_BUCKET_NAME'],
      access_key_id:      ENV['PCONF_DOCUMENTS_AWS_ACCESS_KEY_ID'],
      secret_access_key:  ENV['PCONF_DOCUMENTS_AWS_SECRET_ACCESS_KEY']
    },
  }

  validates_attachment_content_type :attachment, content_type: ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf']
  validates_attachment_file_name    :attachment, matches: [/png\Z/i, /jpe?g\Z/i, /pdf\Z/i]
  validates_attachment_size         :attachment, in: 0..12.megabytes


  private
  Paperclip.interpolates :accident_report_id do |attachment, style|
    attachment.instance.accident_report_id
  end
end
