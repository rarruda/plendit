json.array!(@profile_statuses) do |profile_status|
  json.extract! profile_status, :id, :status
  json.url profile_status_url(profile_status, format: :json)
end
