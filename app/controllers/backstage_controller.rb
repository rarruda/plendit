class BackstageController < ApplicationController

  before_action :authenticate_user!
  before_filter do 
    redirect_to '/' unless current_user && current_user.is_site_admin?
  end

  def index
    @pending_ads_cnt = Ad.where(status: Ad::statuses[:waiting_review]).count
  end

  def broadcast
    if request.post?
      message = (params[:message] || '').strip
      if message.empty?
        REDIS.del('global_broadcast_html')
      else
        REDIS.set('global_broadcast_html', message)
      end
    end
    @message = REDIS.get('global_broadcast_html')
  end

  def pending_ad_reviews
    @ads = Ad.where(status: Ad::statuses[:waiting_review])
  end

end
