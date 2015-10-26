class BackstageController < ApplicationController

  before_action :authenticate_user!
  before_filter do 
    redirect_to '/' unless current_user && current_user.is_site_admin?
  end

  def index
    @pending_ads_cnt = Ad.where(status: Ad::statuses[:waiting_review]).count
    @pending_kyc_cnt = UserDocument.where(status: UserDocument::statuses[:pending_approval]).count
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

  def pending_kyc_reviews
    # prune out license backpages so we don't show two items for a license?
    @user_documents = UserDocument.where(status: UserDocument::statuses[:pending_approval]).decorate
  end

  def kyc_document
    @user_document = UserDocument.find_by(guid: params[:guid]).decorate
    if request.patch?
      @user_document.update(kyc_params)
      if params[:commit] == 'reject'
        @user_document.not_approved!
      elsif params[:commit] == 'approve'
        user_document.approve!
      end
    end
  end

  private

  def kyc_params
    params[:user_document].permit(:rejection_reason, :expires_at)
  end
end
