
# Paperclip:

Paperclip.options[:command_path] = "~/homebrew/bin/"

Paperclip::Attachment.default_options[:storage]      = :s3
Paperclip::Attachment.default_options[:url]          = ":s3_domain_url"
Paperclip::Attachment.default_options[:s3_host_name] = ENV['PCONF_S3_HOST_NAME']
Paperclip::Attachment.default_options[:s3_credentials] = {
  :bucket            => ENV['PCONF_S3_BUCKET_NAME'],
  :access_key_id     => ENV['PCONF_AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['PCONF_AWS_SECRET_ACCESS_KEY']
}

# Allow interpolation of :ad_id
Paperclip.interpolates :ad_id do |attachment, style|
  attachment.instance.ad_id
end

