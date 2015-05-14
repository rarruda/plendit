json.array!(@ad_images) do |ad_image|
  json.extract! ad_image, :id, :ad_id, :description, :weight, :image
  json.url ad_image_url(ad_image, format: :json)
end
