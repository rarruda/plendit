class IdentityRefreshSpidVerificationLevelJob < ActiveJob::Base
  queue_as :low


  def perform(user_id)
    puts "#{DateTime.now.iso8601} Starting IdentityRefreshSpidVerificationLevelJob for user_id: #{user_id}"
    LOG.info message: "Starting IdentityRefreshSpidVerificationLevelJob for user_id: #{user_id}", user_id: user_id

    # for the first local_spid_user_id only:
    local_spid_user_id = Identity.where(provider: 'spid', user_id: user_id).last.uid

    # initialize client:
    spid_client = Utils::SpidClient.new

    if spid_verification_level = spid_client.verification_level(local_spid_user_id)
      LOG.debug "updating SPiD Identity.uid:#{local_spid_user_id} to verification_level: #{spid_verification_level}"
      Identity.where(provider: 'spid', uid: spid_user_id).update_all( verification_level: spid_verification_level )
    else
      LOG.error message: "IdentityRefreshSpidVerificationLevelJob not able to get the verification_level for the user_id: #{user_id}", user_id: user_id
    end

    LOG.info message: "Ending IdentityRefreshSpidVerificationLevelJob for user_id: #{user_id}", user_id: user_id
    puts "#{DateTime.now.iso8601} Ending IdentityRefreshSpidVerificationLevelJob for user_id: #{user_id}"
  end

end
