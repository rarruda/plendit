class MiscController < ApplicationController
  layout "article", only: [ :about, :faq, :contact, :help, :privacy, :terms ]

  def frontpage
    @hide_search_field = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    # FIXME: we should receive requests for postal_code which is 4 chars long.
    #   handling it here, and not in JS is pretty ugly.
    # Return invalid if the post_code does not exist.
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || "ugyldig" ) : "Poststed..." )
  end

  def renter_price_estimate
    price = (params[:price].to_f * 100).to_i
    category = params[:category]
    insurance = params[:insurance]
    final_price  = price * ( 1.0 + Plendit::Application.config.x.platform.fee_in_percent )
    final_price += price * Plendit::Application.config.x.insurance.price_in_percent[category.to_sym] if insurance == 'true'
    render text: '%.2f' % (final_price / 100)
  end
end
