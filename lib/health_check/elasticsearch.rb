class HealthCheck::Elasticsearch < OkComputer::Check
  def check
    if Elasticsearch::Model.client.ping
      mark_message "ElasticSearch answers to pings."
      # For future better checks:
      #Elasticsearch::Model.client.cluster.health <= for cluster health
    else
      mark_failure
      mark_message "ElasticSearch did NOT answer to a ping."
    end
  end
end