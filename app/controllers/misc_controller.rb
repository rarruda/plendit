class MiscController < ApplicationController

  @@postal_codes = YAML.load_file("#{Rails.root}/config/data/postal_codes.yml")

  def frontpage
    @hide_search_field = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    render text: @@postal_codes[params[:postal_code]]
  end

end
