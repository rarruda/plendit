
module MapViewRememberable
  extend ActiveSupport::Concern


  def params_map( params )
    lat = ( ( params[:ne_lat].to_f + params[:sw_lat].to_f ) / 2 )
    lon = ( ( params[:ne_lon].to_f + params[:sw_lon].to_f ) / 2 )
    zl  = params[:zl]
    logger.debug "MAPVIEW_REM current_map from params: lat:#{lat} lon:#{lon} zl:#{zl}"

    return lat, lon, zl
  end
  def cookies_map
    lat, lon, zl = cookies[:map_pos].split("#").map!{ |e| e.split(":")[1] }
    logger.debug "MAPVIEW_REM get_map_view from cookies: lat:#{lat} lon:#{lon} zl:#{zl}"

    return lat, lon, zl
  end

  # get the correct map view from the map defined by values in url/cookies/global defaults
  def get_map_view( params )
    # load what the current map looks like from the url params
    p_lat, p_lon, p_zl = params_map( params )

    logger.debug  "MAPVIEW_REM get_map_view cookies[:map_pos] >>> #{cookies[:map_pos]}"
    if not cookies[:map_pos].nil?
      cookie_lat, cookie_lon, cookie_zl = cookies_map

      # If the values from params and cookies are different, then we save the new values in cookies.
      if p_lat != cookie_lat or p_lon != cookie_lon or p_zl != cookie_zl and map_valid?( p_lat, p_lon, p_zl )
        logger.debug  "MAPVIEW_REM get_map_view USE values from params"

        lat, lon, zl = p_lat, p_lon, p_zl
      else
        logger.debug  "MAPVIEW_REM get_map_view USE values from cookies"

        lat, lon, zl = cookie_lat, cookie_lon, cookie_zl
        return lat, lon, zl
      end
    else
      lat, lon, zl = p_lat, p_lon, p_zl
    end

    return save_map_view lat, lon, zl

    #return lat, lon, zl
  end

  private
  def map_valid?( lat, lon, zl )
    ( Float(lat) rescue nil ) and ( Float(lon) rescue nil ) and ( Integer(zl) rescue nil )
  end

  def save_map_view( lat = nil, lon = nil, zl = nil )
    logger.debug  "MAPVIEW_REM save_map_view got the following >>> lat:#{lat} lon:#{lon} zl:#{zl}"
    #map_pos="lat:000#lon:000#zl:000#mt:000"
    # Keep in mind that rails url-encodes the cookies
    if map_valid? lat, lon, zl
      cookies[:map_pos] = { value: "lat:#{lat}#lon:#{lon}#zl:#{zl}", expires: 3.months.from_now }
      logger.debug  "MAPVIEW_REM save_map_view SAVING cookies[:map_pos] >>> #{cookies[:map_pos]}"
    else
      cookies.delete :map_pos
      logger.debug  "MAPVIEW_REM save_map_view REMOVED cookies[:map_pos] >>> lat:#{lat} lon:#{lon} zl:#{zl} (broken values)"
      lat = Rails.configuration.x.map.default_center_coordinates[:lat]
      lon = Rails.configuration.x.map.default_center_coordinates[:lon]
      zl  = Rails.configuration.x.map.default_zoom_level
      logger.debug  "MAPVIEW_REM save_map_view REMOVED cookies[:map_pos] >>> lat:#{lat} lon:#{lon} zl:#{zl} (new values)"
    end
    return lat, lon, zl
  end
end