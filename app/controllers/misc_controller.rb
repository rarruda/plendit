class MiscController < ApplicationController
  layout 'article', only: [ :about, :contact, :help, :privacy, :terms, :issues, :welcome ]

  def frontpage
    @hide_search_field = true
    @ads = get_frontpage_ads rescue [] # todo, figure out why this throws in test
    @hero_video = Rails.configuration.x.frontpage.hero_videos.sample
  end

  def about
    @employees = YAML
      .load_file("#{Rails.root}/config/data/employees.yml")
      .map { |e| OpenStruct.new(e) }
  end

  def postal_place
    render text: ( params[:postal_code].length == 4 ? ( POSTAL_CODES[params[:postal_code]] || 'ugyldig' ) : 'Poststed...' )
  end

  def terms
  end

  def privacy
  end

  def welcome
  end

  private

  def get_frontpage_ads
    ids = get_frontpage_ad_ids
    ads = ids.map { |id| Ad.find_by(id: id) }.compact

    if ads.size != ids.size
      LOG.warn message: 'Frontpage ads list contains unpublished ads!'
    end

    if ads.size < 6
      ads = ads + Ad.published[13...-1]
    end

    ads = ads.uniq[0...6]

    if ads.size != 6
      LOG.warn message: 'Unable to find 6 ads for frontpage!'
    end

    ads.map { |ad| RecursiveOpenStruct.new(ad.as_indexed_json) }
  end

  def parse_frontpage_ad_ids id_string
    id_string.split(',').map(&:strip)
  end

  def get_frontpage_ad_ids
    parse_frontpage_ad_ids(REDIS.get('global_frontpage_ads') || '')
  end

end
