class MiscController < ApplicationController

  def frontpage
    @show_search_field = true
    # Fixme: this should just be the current logged in user object, or nil, not a bool
    @has_user = true
  end

  def ad
    @ad = Ad.find(1)
  end

  def create_1
  end

  def create_2
  end

  def create_3
  end

  def result
    @ads = Ad.where('LOWER(title) LIKE LOWER(?) OR LOWER(body) LIKE LOWER(?)', "%#{params[:q]}%", "%#{params[:q]}%" )
    @term = params[:q]
  end

  def faq
  end

  def about
  end

  def personal_requests
  end

end
