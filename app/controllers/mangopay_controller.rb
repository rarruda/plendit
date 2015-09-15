class MangopayController < ApplicationController
  def callback
    # register the callback call data in the database
    #puts "remote_ip: #{request.remote_ip} #{request.original_url}"
    cb = {
      event_type_mp: request.query_parameters['EventType'],
      resource_vid:  request.query_parameters['RessourceId'],
      date_mp:       request.query_parameters['Date'],
      remote_ip:     request.remote_ip,
      raw_data:      "#{request.request_method} #{request.original_url}"
    }

    webhook = MangopayWebhook.new(cb)

    respond_to do |format|
      if webhook.save
        format.html { head :no_content }
        format.json { head :no_content }
      else
        format.html { render :callback, status: :unprocessable_entity }
        format.json { render json: { status: failed }, status: :unprocessable_entity }
      end
    end
  end
end
