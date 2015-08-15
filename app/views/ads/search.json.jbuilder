json.center @center
json.hits do
  json.array! @ads do |ad|
    json.id ad._id
    json.location ad._source.geo_location
    json.title ad._source.title
    json.price ad._source.price
    json.body ad._source.body
  end
end
json.markup @result_markup