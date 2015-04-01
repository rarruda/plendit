class MiscController < ApplicationController
  def frontpage
    @show_search_field = true
  end

  def ad
    @ad = Ad.find(1)
  end

  def faq
  end

  def about
  end
end
