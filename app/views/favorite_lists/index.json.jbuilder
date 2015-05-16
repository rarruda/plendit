json.array!(@favorite_lists) do |favorite_list|
  json.extract! favorite_list, :id, :user_id, :name
  json.url favorite_list_url(favorite_list, format: :json)
end
