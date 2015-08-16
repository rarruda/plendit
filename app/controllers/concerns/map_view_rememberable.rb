
module MapViewRememberable
  extend ActiveSupport::Concern


  def params_map( params )
    lat = ( ( params[:ne_lat].to_f + params[:sw_lat].to_f ) / 2 )
    lon = ( ( params[:ne_lon].to_f + params[:sw_lon].to_f ) / 2 )
    zl  = params[:zl]
    logger.debug "MAPVIEW_REM current_map from params: lat:#{lat} lon:#{lon} zl:#{zl}"

    return lat, lon, zl
  end

  # get the correct map view from the map defined by values in url/cookies/global defaults
  def get_map_view( params )
    # load what the current map looks like from the url params
    lat, lon, zl = params_map(params)

    if cookies[:map_pos]
      cookie_lat, cookie_lon, cookie_zl = cookies[:map_pos].split("#").map!{ |e| e.split(":")[1] }
      logger.debug "MAPVIEW_REM get_map_view from cookies: lat:#{cookie_lat} lon:#{cookie_lon} zl:#{cookie_zl}"

      # If the values from params and cookies are different, then we save the new values in cookies.
      if lat != cookie_lat or lon != cookie_lon or zl != cookie_zl
        return save_map_view lat, lon, zl
      end

    else
      logger.debug  "MAPVIEW_REM get_map_view checking if current latlonzl are valid >>> lat:#{lat} lon:#{lon} zl:#{zl}"
      if ( Float(lat) rescue nil ) and ( Float(lon) rescue nil ) and ( Integer(zl) rescue nil )
        #map_pos="lat:000#lon:000#zl:000#mt:000"
        cookies[:map_pos] = { value: "lat:#{lat}#lon:#{lon}#zl:#{zl}", expires: 3.months.from_now }
        logger.debug  "MAPVIEW_REM get_map_view SAVING cookies[:map_pos] >>> #{cookies[:map_pos]}"
      else
        cookies.delete :map_pos
        logger.debug  "MAPVIEW_REM get_map_view supplied values found to be invalid >>> lat:#{lat} lon:#{lon} zl:#{zl}"
        lat = Rails.configuration.x.map.default_center_coordinates[:lat]
        lon = Rails.configuration.x.map.default_center_coordinates[:lon]
        zl  = Rails.configuration.x.map.default_zoom_level
        logger.debug  "MAPVIEW_REM get_map_view using default values >>> lat:#{lat} lon:#{lon} zl:#{zl}"
      end
    end
    return save_map_view lat, lon, zl

    #return lat, lon, zl
  end

  private
  def save_map_view( lat = 0, lon = 0, zl = 0 )
    #map_pos="lat:000#lon:000#zl:000#mt:000"
    # Keep in mind that rails url-encodes the cookies
    if ( Float(lat) rescue nil ) and ( Float(lon) rescue nil ) and ( Integer(zl) rescue nil )
      cookies[:map_pos] = { value: "lat:#{lat}#lon:#{lon}#zl:#{zl}", expires: 3.months.from_now }
      logger.debug  "MAPVIEW_REM save_map_view SAVING cookies[:map_pos] >>> #{cookies[:map_pos]}"
    else
      cookies.delete :map_pos
      logger.debug  "MAPVIEW_REM save_map_view REMOVED cookies[:map_pos] >>> lat:#{lat} lon:#{lon} zl:#{zl} (as the values were found to be invalid."
    end
    return lat, lon, zl
  end
end