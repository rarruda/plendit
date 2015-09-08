json.center @map_center
json.zl @map_zl
json.markup @result_markup

json.paging do
  json.total_count @ads.total_count
  json.total_pages @ads.total_pages
  json.current_page @ads.current_page
  json.num_pages @ads.num_pages
  json.default_per_page @ads.default_per_page
end

json.ads do
  @ads.each do |ad|
    json.set! ad._id do
      json.id ad._id
      json.location ad._source.geo_location
      json.geohash ad.fields['geo_location.geohash'].last
      json.title ad._source.title
      json.price ad._source.price
      json.body ad._source.body
      json.image_url ad_image_url(ad._id)
      json.listing_url (ad_path ad._id)
    end
  end
end

json.groups do
  json.array! @ads.group_by { |ad| ad.fields['geo_location.geohash'].last }.values.each do |group|
    json.geohash group.first.fields['geo_location.geohash'].last
    json.location group.first._source.geo_location
    json.hits group.map { |ad| ad._id }
  end
end