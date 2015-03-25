json.array!(@ad_items) do |ad_item|
  json.extract! ad_item, :id, :ad_id
  json.url ad_item_url(ad_item, format: :json)
end
