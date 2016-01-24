class MangopayController < ApplicationController
  def callback
    # register the callback call data in the database
    cb = {
      event_type:    request.query_parameters['EventType'],
      resource_vid:  request.query_parameters['RessourceId'],
      timestamp_v:   request.query_parameters['Date'],
      remote_ip:     request.remote_ip,
      raw_data:      "#{request.request_method} #{request.original_url}"
    }

    webhook = MangopayWebhook.new(cb)

    if webhook.save
      head :ok
    else
      render :callback, status: :unprocessable_entity
    end
  end
end

# event_type_mp => event_type
# resource_type
# resource_vid
# date_mp => time_v