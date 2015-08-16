json.center @map_center
json.zl @map_zl
json.hits do
  json.array! @ads do |ad|
    json.id ad._id
    json.location ad._source.geo_location
    json.title ad._source.title
    json.price ad._source.price
    json.body ad._source.body
  end
end
json.paging do
  json.total_count @ads.total_count
  json.total_pages @ads.total_pages
  json.current_page @ads.current_page
  json.num_pages @ads.num_pages
  json.default_per_page @ads.default_per_page
end
json.markup @result_markup