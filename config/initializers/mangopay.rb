MangoPay.configure do |c|
  c.preproduction     = ENV['PCONF_MANGOPAY_PREPRODUCTION'] == "false" ? false : true
  c.client_id         = ENV['PCONF_MANGOPAY_CLIENT_ID']
  c.client_passphrase = ENV['PCONF_MANGOPAY_CLIENT_PASSPHRASE']
end

# Config for creating callback urls:
#PCONF_MANGOPAY_CALLBACK_BASE_URL = ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL']
