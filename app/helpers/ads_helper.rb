module AdsHelper

  def ad_image_url(ad_id)
    Ad.find(ad_id).decorate.result_image_url
  end

end
