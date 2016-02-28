class UnavailabilitiesCleanupJob < ActiveJob::Base
  queue_as :low

  def perform(*args)
    Unavailability
        .unscoped
        .where('ends_at < ?', Date.yesterday)
        .each &:destroy
  end
end
