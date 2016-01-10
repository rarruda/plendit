class MiscController < ApplicationController
  layout "article", only: [ :about, :contact, :help, :privacy, :terms, :issues ]

  def frontpage
    @hide_search_field = true
    @ads = Ad.published
             .includes(:location,:payin_rules,:ad_images,:user)
             .order(:updated_at)
             .limit(6)
             .map { |ad| RecursiveOpenStruct.new(ad.as_indexed_json) }
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def about
    @employees = YAML
      .load_file("#{Rails.root}/config/data/employees.yml")
      .map { |e| OpenStruct.new(e) }
  end

  def postal_place
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || "ugyldig" ) : "Poststed..." )
  end

  def terms
  end

  def privacy
  end

end
