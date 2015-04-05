class MiscController < ApplicationController
  skip_before_filter :authorize

  def frontpage
    @show_search_field = true
    # Fixme: this should just be the current logged in user object, or nil, not a bool
    @has_user = true
  end

  def ad
    @ad = Ad.find(1)
  end

  def faq
  end

  def about
  end
end
