class MiscController < ApplicationController
  layout "article", only: [ :about, :contact, :help, :privacy, :terms, :issues ]

  def frontpage
    @hide_search_field = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || "ugyldig" ) : "Poststed..." )
  end

  def renter_price_estimate
    price = (params[:price].to_f * 100).to_i
    category = params[:category].to_sym
    insurance = params[:insurance] == 'true' || Plendit::Application.config.x.insurance.is_required[category]
    final_price  = price * ( 1.0 + Plendit::Application.config.x.platform.fee_in_percent )
    final_price += price * Plendit::Application.config.x.insurance.price_in_percent[category.to_sym] if insurance == 'true'
    render text: '%.2f' % (final_price / 100)
  end
end
