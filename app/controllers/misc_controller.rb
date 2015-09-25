class MiscController < ApplicationController
  layout "article", only: [ :about, :faq, :contact, :help, :privacy, :terms ]

  def frontpage
    @hide_search_field = true
    @overlaid_top_bar = true
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def postal_place
    # FIXME: we should receive requests for postal_code which is 4 chars long.
    #   handling it here, and not in JS is pretty ugly.
    # Return invalid if the post_code does not exist.
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || "ugyldig" ) : "Poststed..." )
  end

  #def price_estimate(price, category, insurance)
  #  price = params[:price]
  #  category = params[:category]
  #  insurance = params[:insurance]
  #  final_price  = price * ( 1 + PLENDIT_FEE_PCT )
  #  final_price += price * ( 1 + PLENDIT_INSURANCE_FEES[category] ) if insurance
  #  render text: ( final_price )
  #end
end
