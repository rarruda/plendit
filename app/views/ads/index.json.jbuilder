json.array!(@ads) do |ad|
  json.extract! ad, :id, :profile_id, :title, :short_description, :body, :price, :tags
  json.url ad_url(ad, format: :json)
end
