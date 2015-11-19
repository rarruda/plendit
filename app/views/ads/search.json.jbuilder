json.map_bounds @map_bounds
json.zl @map_zl
json.markup @result_markup

json.paging do
  json.total_count @ads.total_count
  json.total_pages @ads.total_pages
  json.current_page @ads.current_page
  json.num_pages @ads.num_pages
  json.default_per_page @ads.default_per_page
end

json.cache! ['json_ad_list', @ads.map{|e| e.id}], expires_in: 10.minutes do
  json.ads do
    @ads.each do |ad|
      json.cache! ['json_ad_item', ad.id], expires_in: 10.minutes do
        json.set! ad.id do
          json.id ad.id
          json.location ad._source.geo_location
          json.geohash ad.fields['geo_location.geohash'].last
          json.title ad.title
          json.price ad.price
          json.body ad.body
          json.image_url ad.main_image_url
          json.listing_url (ad_path ad.id)
        end
      end
    end
  end
end

json.groups do
  json.array! @ads.group_by { |ad| ad.fields['geo_location.geohash'].last }.values.each do |group|
    json.geohash group.first.fields['geo_location.geohash'].last
    json.location group.first._source.geo_location
    json.hits group.map { |ad| ad.id }
  end
end