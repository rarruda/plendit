module MapViewRememberable
  extend ActiveSupport::Concern

  @@bounds_schema = {
    'ne_lat' => Float,
    'ne_lon' => Float,
    'sw_lat' => Float,
    'sw_lon' => Float,
    'zl'     => Integer
  }

  def get_search_bounds( params )
    bounds_from_params(params) || bounds_from_cookie || Rails.configuration.x.map.default_bounds
  end

  def valid_bounds?( bounds )
    RSchema.validate(@@bounds_schema, bounds)
  end

  def bounds_from_params( params )
    bounds = params.select { |k, v| ['ne_lat','ne_lon','sw_lat','sw_lon'].include? k }.keep_if { |k,v| not v.blank? }
    bounds = bounds.merge(bounds) { |k, v| Float(v) } rescue nil
    bounds['zl'] = Integer(params['zl']) rescue nil
    bounds if (valid_bounds? bounds)
  end

  def bounds_from_cookie
    bounds = JSON.parse(cookies[:map_bounds]) rescue nil
    bounds if (valid_bounds? bounds)
  end

  def save_map_bounds( bounds )
    cookies[:map_bounds] = {value: JSON.generate(bounds), expires: 1.hour.from_now}
  end
end