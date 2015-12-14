module BookingsHelper

  def parse_datetime_params params, label, utc_or_local = :local
    begin
      year   = params[(label.to_s + '(1i)').to_sym].to_i
      month  = params[(label.to_s + '(2i)').to_sym].to_i
      mday   = params[(label.to_s + '(3i)').to_sym].to_i
      hour   = (params[(label.to_s + '(4i)').to_sym] || 0).to_i
      minute = (params[(label.to_s + '(5i)').to_sym] || 0).to_i
      second = (params[(label.to_s + '(6i)').to_sym] || 0).to_i

      return DateTime.civil_from_format(utc_or_local,year,month,mday,hour,minute,second)
    rescue => e
      return nil
    end
  end

end
