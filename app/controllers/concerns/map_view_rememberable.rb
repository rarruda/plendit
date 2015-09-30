module MapViewRememberable
  extend ActiveSupport::Concern

  def get_search_bounds( params )
    bounds_from_params(params) || bounds_from_cookie || Rails.configuration.x.map.default_bounds
  end

  def valid_bounds?( bounds )
    valid = !bounds.nil? && bounds.size == 4
    LOG.debug valid.to_s
    LOG.debug bounds.to_s
    valid
  end

  def bounds_from_params( params )
    bounds = params.select { |k, v| ['ne_lat','ne_lon','sw_lat','sw_lon'].include? k }.keep_if { |k,v| not v.blank? }
    bounds = bounds.merge(bounds) { |k, v| Float(v) } rescue nil
    return bounds if (valid_bounds? bounds) else nil
  end

  def bounds_from_cookie
    bounds = JSON.parse cookies[:map_bounds] rescue nil
    return bounds if (valid_bounds? bounds) else nil
  end

  def save_map_bounds( bounds )
    cookies[:map_bounds] = JSON.generate bounds
  end
end