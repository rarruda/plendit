class Utils::SpidClient
  require 'oauth2'

  # client:
  def initialize
    @client = OAuth2::Client.new(
      ENV['PCONF_SPID_CLIENT_ID'],
      ENV['PCONF_SPID_CLIENT_SECRET'],
      site: ENV['PCONF_SPID_CLIENT_URL']
    )
    @token = @client.client_credentials.get_token
  end


  def verification_level(spid_user_id)
    begin
      response = @token.get( "/api/2/user/#{spid_user_id}/level", params: {oauth_token: @token.token} )
    rescue => e
      LOG.error message: "unable to get a valid reponse for the request from the server: e:#{e}", spid_user_id: spid_user_id
      return nil
    end

    begin
      response_object = JSON.parse( response.body )

      data      = response_object['data']
      signature = response_object['sig']
      algorithm = response_object['algorithm']

      spid_verification_level = JSON.parse(Base64.decode64(data))['level']
      spid_user_id            = JSON.parse(Base64.decode64(data))['userId']

      LOG.debug message: "decoded response data:#{Base64.decode64(data)}"
    rescue => e
      LOG.error message: "unable to decode response from the server: e:#{e}"
      return nil
    end


    if valid_signature?(data,algorithm,signature)
      LOG.info message: "valid response: spid_user_id: #{spid_user_id} has verification_level: #{spid_verification_level}"
      return spid_verification_level
    else
      LOG.error message: "invalid server signature, ignoring the response", spid_user_id: spid_user_id
      return nil
    end
  end

  private
  # data and signature parameters should be base64 encoded
  def valid_signature?(data,algorithm,signature)
    # we only know how to deal with the SHA256 algorithm:
    # http://techdocs.spid.no/endpoints/#signed-responses
    if algorithm == 'HMAC-SHA256'
      expected_signature = OpenSSL::HMAC.digest('sha256', ENV['PCONF_SPID_CLIENT_SIG_SECRET'], data)
    else
      LOG.error message: "unknown signature algorithm: #{algorithm}"
      return false
    end

    return false if expected_signature != Base64.decode64(signature)
    true
  end

end

# update all current identities spid:
# spid_client = Utils::SpidClient.new
# Identity.all.where(provider: 'spid', verification_level: nil).each{ |i|
#   i.update( verification_level: spid_client.verification_level(i.uid) )
# }