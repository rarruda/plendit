class HealthCheck::Random < OkComputer::Check
  def check
    if rand(10).even?
      mark_message "Even is great!"
    else
      mark_failure
      mark_message "We don't like odd numbers"
    end
  end
end