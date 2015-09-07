json.array!(@bookings) do |booking|
  json.extract! booking, :id, :ad_item_id, :from_user_id, :status, :amount, :starts_at, :ends_at, :first_reply_at
  json.url booking_url(booking, format: :json)
end
