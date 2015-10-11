module AdsHelper

  def ad_image_url(ad_id)
    Ad.find(ad_id).decorate.result_image_url
  end

  def current_user_is_owner(ad)
    user_signed_in? && (current_user.owns_ad? ad)
  end

  def status_label(ad)
    colors = {
        published:       'green',
        draft:           'yellow',
        waiting_review:  'yellow',
        paused:          'yellow',
        stopped:         'red',
        deleted:         'red'
    }
    colors.default = 'black'
  
    color = colors[ad.status.to_sym]
    content_tag :span, ad.decorate.display_status.titlecase, class: "status-label status-label--#{color}"
  end

end
