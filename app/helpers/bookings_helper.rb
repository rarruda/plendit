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

  def booking_status_label(booking)
    colors = {
        created:           'yellow',
        payment_preauthorized: 'green',
        confirmed:         'green',
        payment_confirmed: 'green',
        started:           'green',
        in_progress:       'green',
        ended:             'green',
        archived:          'green',
        aborted:           'red',
        cancelled:         'black',
        declined:          'black',
        dispute_agreed:    'black',
        dispute_disagreed: 'red',
        disputed:          'red',
        admin_paused:      'red',
        payment_failed:    'red',
        payment_preauthorization_failed: 'red',
    }
    colors.default = 'black'

    color = colors[booking.status.to_sym]
    content_tag :span, booking.decorate.display_status.capitalize, class: "status-label status-label--#{color}"
  end

end
