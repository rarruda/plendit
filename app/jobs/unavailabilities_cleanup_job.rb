class UnavailabilitiesCleanupJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Unavailability
        .unscoped
        .where('ends_at < ?', Date.today)
        .each &:destroy
  end
end
