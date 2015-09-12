module AdsHelper

  def ad_image_url(ad_id)
    Ad.find(ad_id).decorate.result_image_url
  end

  def current_user_is_owner(ad)
    user_signed_in? && (current_user.owns_ad? ad)
  end

end
