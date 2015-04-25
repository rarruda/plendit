class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider


  def self.find_for_oauth(auth)
    identity = find_or_create_by(uid: auth.uid, provider: auth.provider) do |i|
      i.image_url = auth.info.image

      # Set user.image_url only if its empty
      if not i.user.nil? and i.user.image_url.nil?
        i.user.image_url = i.image_url
      end

      case auth.provider
      when 'facebook'
        #i.profile_url = auth.urls.facebook
        i.profile_url = auth.extra.raw_info.link
      when 'google_oauth2' # || 'google'
        i.profile_url = auth.extra.raw_info.profile
      end
    end
  end

end
