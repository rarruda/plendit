
# Paperclip:

Paperclip.options[:command_path] = "~/homebrew/bin/"

Paperclip::Attachment.default_options[:storage]        = :s3
Paperclip::Attachment.default_options[:url]            = ":s3_alias_url"
Paperclip::Attachment.default_options[:s3_protocol]    = 'https'
Paperclip::Attachment.default_options[:s3_host_name]   = ENV['PCONF_S3_HOST_NAME']
Paperclip::Attachment.default_options[:s3_host_alias]  = ENV['PCONF_S3_CDN_ALIAS']
Paperclip::Attachment.default_options[:s3_credentials] = {
  :bucket            => ENV['PCONF_S3_BUCKET_NAME'],
  :access_key_id     => ENV['PCONF_AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['PCONF_AWS_SECRET_ACCESS_KEY']
}
Paperclip::Attachment.default_options[:preserve_files] = false
# :preserve_files => "true", #Soft-delete (delete only from database, not from storage/s3)
# for s3 options see: http://www.rubydoc.info/gems/paperclip/Paperclip/Storage/S3
# https://github.com/thoughtbot/paperclip/wiki/Restricting-Access-to-Objects-Stored-on-Amazon-S3

# NOTE: Keep in mind, we use a different bucket for user_documents. (with different credentials...)


# Allow interpolation of :ad_id and user_id
Paperclip.interpolates :ad_id do |attachment, style|
  attachment.instance.ad_id
end
Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end
