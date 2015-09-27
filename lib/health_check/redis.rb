class HealthCheck::Redis < OkComputer::Check
  def check
    if REDIS.ping == "PONG"
      mark_message "Redis answers to pings."
    else
      mark_failure
      mark_message "Redis did NOT answer to a ping."
    end
  end
end