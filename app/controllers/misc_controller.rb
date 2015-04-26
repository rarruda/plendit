class MiscController < ApplicationController

  def frontpage
    @hide_search_field = true
  end

  def result
    @ads = Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{params[:q]}%", "%#{params[:q]}%" )
    @term = params[:q]
  end

  # work in progress page for experimenting with partials and stuff. Don't refactor yet
  def wip
    @ads = Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{params[:q]}%", "%#{params[:q]}%" )
    @ad = @ads[0]
  end

end
