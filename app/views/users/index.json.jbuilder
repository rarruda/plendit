json.array!(@users) do |user|
  json.extract! user, :id, :name, :phome_number, :join_timestamp, :last_action_timestamp, :private_link_to_facebook, :private_link_to_linkedin, :ephemeral_answer_percent
  json.url user_url(user, format: :json)
end
