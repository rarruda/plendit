class BackstageController < ApplicationController

  skip_before_action :enable_chat

  before_action :authenticate_user!
  before_filter do
    redirect_to '/' unless current_user && current_user.is_site_admin?
  end

  def index
    @pending_ads_cnt = Ad.where(status: Ad::statuses[:waiting_review]).count
    @pending_kyc_cnt = UserDocument.where(status: UserDocument::statuses[:pending_approval]).count
    @revision = get_current_revision
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

  def frontpage_ads
    @current_ad_ids = (REDIS.get('global_frontpage_ads') || '').split(',').map(&:strip)
    @current_ads = @current_ad_ids.map {|id| Ad.find_by(id: id)}
    @new_ad_ids = (params[:new_ad_ids] || '').split(',').map(&:strip)
    @new_ads = @new_ad_ids.map {|id| Ad.find_by(id: id)}
    @new_ads_ok = @new_ads.select(&:present?).size >= 6
  end

  def save_frontpage_ads
    #fixme, final sanity check before saving
    save_frontpage_ad_ids(parse_frontpage_ad_ids params[:ad_ids])
    redirect_to frontpage_ads_path
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
        unless @user_document.drivers_license_back?
          notify_about_kyc @user_document
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
    @bookings = Booking.boat_insurer_visible
  end

  private

  def parse_frontpage_ad_ids id_string
    id_string.split(',').map(&:strip)
  end

  def get_frontpage_ad_ids
    parse_frontpage_ad_ids(REDIS.get('global_frontpage_ads') || '')
  end

  def save_frontpage_ad_ids ids
    REDIS.set('global_frontpage_ads', ids.join(','))
  end

  def notify_about_kyc doc
    msg = "#{doc.display_category} ble #{doc.approved? ? 'godkjent' : 'avvist'}."
    Notification.new(
      user_id: doc.user.id,
      is_system_message: true,
      message: msg,
      notifiable: doc).save
  end

  def kyc_params
    params.require(:user_document).permit(:rejection_reason, :expires_at,
      user_attributes: [:birthday, :personal_id_number, :verification_level,
        :first_name, :last_name, :id]
    )
  end

  def get_current_revision
    File.read("#{Rails.root.to_s}/REVISION") rescue 'unknown'
  end
end
