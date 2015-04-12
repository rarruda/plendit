json.array!(@messages) do |message|
  json.extract! message, :id, :booking_id, :from_user_id, :to_user_id, :content
  json.url message_url(message, format: :json)
end
