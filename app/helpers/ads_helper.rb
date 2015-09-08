module AdsHelper

  def ad_image_url(ad_id)
    Ad.find(ad_id).safe_image_url(:searchresult)
  end

end
