class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider


  def self.find_for_oauth(auth)

    # for debugging information coming from the different auth providers:
    #pp auth

    identity = find_or_create_by(uid: auth.uid, provider: auth.provider) do |i|
      i.email      = auth.info.email
      i.name       = auth.info.name
      i.first_name = auth.info.first_name
      i.last_name  = auth.info.last_name

      case auth.provider
      when 'facebook'
        #i.profile_url = auth.urls.facebook
        i.profile_url = auth.extra.raw_info.link
        i.image_url   = auth.info.image
        i.nickname    = auth.info.nickname
      when 'google'
        i.profile_url = auth.extra.raw_info.profile
        i.image_url   = auth.extra.raw_info.picture
      when 'spid'
        i.profile_url = auth.extra.raw_info.url
        i.image_url   = auth.info.image
        i.nickname    = auth.info.nickname
      else
        LOG.error "unsupported auth.provider:#{auth.provider}, dropping some information on the floor"
      end

      # Set user.image_url only if its empty
      if not i.user.nil? and i.user.image_url.nil?
        i.user.image_url = i.image_url
      end

    end
  end

end
