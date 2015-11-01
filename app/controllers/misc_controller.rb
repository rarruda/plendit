class MiscController < ApplicationController
  layout "article", only: [ :about, :contact, :help, :privacy, :terms, :issues ]

  def frontpage
    @hide_search_field = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || "ugyldig" ) : "Poststed..." )
  end
end
