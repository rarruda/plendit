class MiscController < ApplicationController
  layout "article", only: [ :about, :faq, :contact, :help, :privacy, :terms ]

  def frontpage
    @hide_search_field = true
    @overlaid_top_bar = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    render text: POSTAL_CODES[params[:postal_code]]
  end

end
