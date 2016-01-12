class BackstageController < ApplicationController

  skip_before_action :enable_chat

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
    @user_documents = UserDocument.pending_approval.decorate
  end

  def kyc_document
    #fixme: redirect to kyc index when approved?
    @user_document = UserDocument.find_by(guid: params[:guid]).decorate
    if request.patch?
      if @user_document.update(kyc_params)
        if params[:commit] == 'reject'
          @user_document.not_approved!
        elsif params[:commit] == 'approve'
          @user_document.approved!
        end
      else
        # was not able to update, likely a validation error.
      end
    end
  end

  def kyc_image
    user_document = UserDocument.find_by(guid: params[:guid])
    redirect_to user_document.document.expiring_url(10)
  end

  def boat_admin
    @bookings = Booking.current.joins(:ad).where(ads: {category: Ad.categories[:boat]})
  end

  private

  def kyc_params
    params.require(:user_document).permit(:rejection_reason, :expires_at,
      user_attributes: [:birthday, :personal_id_number, :verification_level,
        :first_name, :last_name, :id]
    )
  end
end
