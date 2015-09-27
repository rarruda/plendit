class HealthCheck::Mangopay < OkComputer::Check
  def check
    begin
      res = MangoPay::Event.fetch page: 1, per_page: 1
      mark_message "Mangopay API is great!"
    rescue MangoPay::ResponseError => ex
      mark_failure
      mark_message "Mangopay API connection failed. Rensponse error: #{ex.details}"
    rescue
      mark_failure
      mark_message "Mangopay API connection failed. error: #{ex.details}"
    end
  end
end