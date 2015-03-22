json.array!(@profiles) do |profile|
  json.extract! profile, :id, :name, :phome_number, :join_timestamp, :last_action_timestamp, :private_link_to_facebook, :private_link_to_linkedin, :ephemeral_answer_percent
  json.url profile_url(profile, format: :json)
end
