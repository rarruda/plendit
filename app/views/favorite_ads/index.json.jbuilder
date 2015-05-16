json.array!(@favorite_ads) do |favorite_ad|
  json.extract! favorite_ad, :id, :favorite_list_id, :ad_id
  json.url favorite_ad_url(favorite_ad, format: :json)
end
