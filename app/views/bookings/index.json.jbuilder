json.array!(@bookings) do |booking|
  json.extract! booking, :id, :ad_item_id, :from_profile_id, :booking_status_id, :price, :price, :booking_from, :booking_to, :first_reply_at
  json.url booking_url(booking, format: :json)
end
