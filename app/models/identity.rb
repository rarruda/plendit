class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider


  def self.find_for_oauth(auth)
    identity = find_or_create_by(uid: auth.uid, provider: auth.provider) do |i|
      i.email      = auth.info.email
      i.name       = auth.info.name

      case auth.provider
      when 'facebook'
        #i.profile_url = auth.urls.facebook
        i.profile_url = auth.extra.raw_info.link
        i.nickname    = auth.info.nickname
        i.image_url   = auth.info.image
        i.first_name  = auth.info.first_name
        i.last_name   = auth.info.last_name
      when 'google_oauth2' # || 'google'
        i.profile_url = auth.extra.raw_info.profile
        i.image_url   = auth.extra.raw_info.picture
        i.first_name  = auth.info.first_name
        i.last_name   = auth.info.last_name
      when 'spid'
        i.profile_url = auth.extra.raw_info.url
        i.nickname    = auth.info.nickname
        i.image_url   = auth.info.image
        i.first_name  = auth.info.raw_info.name.givenName
        i.last_name   = auth.info.raw_info.name.familyName
      else
        logger.error "unsupported auth.provider:#{auth.provider}, dropping some information on the floor"
      end

      # Set user.image_url only if its empty
      if not i.user.nil? and i.user.image_url.nil?
        i.user.image_url = i.image_url
      end

    end
  end

end
