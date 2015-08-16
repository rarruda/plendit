
module MapViewRememberable
  extend ActiveSupport::Concern


  def current_map( params )
    cur_lat = ( ( params[:ne_lat].to_f + params[:sw_lat].to_f ) / 2 )
    cur_lon = ( ( params[:ne_lon].to_f + params[:sw_lon].to_f ) / 2 )
    cur_zl  = params[:zl]
    logger.debug "MAPVIEW_REM current_map from params: lat:#{cur_lat} lon:#{cur_lon} zl:#{cur_zl}"

    return cur_lat, cur_lon, cur_zl
  end

  # get the correct map view from the map defined by values in url/cookies/global defaults
  def get_map_view( params )
    # load what the current map looks like from the url params
    lat, lon, zl = current_map(params)
    #logger.debug "MAPVIEW_REM get_map_view current from params: lat:#{lat} lon:#{lon} zl:#{zl}"

    if cookies[:map_pos]
      cookie_lat, cookie_lon, cookie_zl = cookies[:map_pos].split("#").map!{ |e| e.split(":")[1] }
      logger.debug "MAPVIEW_REM get_map_view from cookies: lat:#{cookie_lat} lon:#{cookie_lon} zl:#{cookie_zl}"

      # If the values from params and cookies are different, then we save the new values in cookies.
      if lat != cookie_lat or lon != cookie_lon or zl != cookie_zl
        save_map_view lat, lon, zl
      end

      # And use the new values
      return cookie_lat, cookie_lon, cookie_zl
    else
      if lat.blank? or lon.blank? or zl.blank?
        logger.debug  "MAPVIEW_REM get_map_view loading global defaults >>> lat:#{lat} lon:#{lon} zl:#{zl}"

        lat = Rails.configuration.x.map.default_center_coordinates[:lat]
        lon = Rails.configuration.x.map.default_center_coordinates[:lon]
        zl  = Rails.configuration.x.map.default_zoom_level
      else
        save_map_view lat, lon, zl
      end
    end
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
  end
end