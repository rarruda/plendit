class MiscController < ApplicationController

  @@postal_codes = YAML.load_file("#{Rails.root}/config/data/postal_codes.yml")
  @@popular_topics = YAML.load_file("#{Rails.root}/config/data/popular_topics.yml")

  def frontpage
    @hide_search_field = true
    @popular_topics = @@popular_topics
  end

  def postal_place
    render text: @@postal_codes[params[:postal_code]]
  end

end
