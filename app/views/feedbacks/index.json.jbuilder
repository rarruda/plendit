json.array!(@feedbacks) do |feedback|
  json.extract! feedback, :id, :ad_id, :from_profile_id, :score, :body
  json.url feedback_url(feedback, format: :json)
end
