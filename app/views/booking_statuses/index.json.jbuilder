json.array!(@booking_statuses) do |booking_status|
  json.extract! booking_status, :id, :status
  json.url booking_status_url(booking_status, format: :json)
end
