class UnavailabilitiesCleanupJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Unavailability
        .unscoped
        .where('ends_at < ?', Date.yesterday)
        .each &:destroy
  end
end
