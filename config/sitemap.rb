
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host  = "https://#{Rails.application.routes.default_url_options[:host] || 'www.plendit.no'}"

SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
    fog_provider:          'AWS',
    aws_access_key_id:     ENV['PCONF_AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['PCONF_AWS_SECRET_ACCESS_KEY'],
    fog_directory:         ENV['PCONF_S3_BUCKET_NAME'],
    fog_region:            ENV['PCONF_S3_REGION'] || 'eu-central-1', #less evil
  )

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path   = 'tmp/'

# The remote host where your sitemaps will be hosted
SitemapGenerator::Sitemap.sitemaps_host = "https://#{ENV['PCONF_S3_CDN_ALIAS']}/"

# Set this to a directory/path if you don't want to upload to the root of your `sitemaps_host`
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

# NOTE: Sitemaps are delivered by apache, bypassing our app.

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add about_us_path, changefreq: 'weekly', priority: 0.7
  add contact_path,  changefreq: 'weekly', priority: 0.7
  add privacy_path,  changefreq: 'weekly'
  add terms_path,    changefreq: 'weekly'

  # signup/login pages:
  add new_user_registration_path, changefreq: 'weekly', priority: 0.75
  add new_user_session_path,      changefreq: 'weekly', priority: 0.75

  # one for each published ad/listing
  # Should we index hero (smaller, cropped) or gallery (larger, non-cropped) images?
  Ad.published.find_each do |a|
    add ad_path(a),
      lastmod: a.updated_at,
      images: a.ad_images.map{ |ai| { loc: ai.image.url(:hero), caption: ai.description } },
      changefreq: 'daily'
  end
end
