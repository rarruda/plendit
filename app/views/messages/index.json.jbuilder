json.array!(@messages) do |message|
  json.extract! message, :id, :booking_id, :from_profile_id, :to_profile_id, :content
  json.url message_url(message, format: :json)
end
