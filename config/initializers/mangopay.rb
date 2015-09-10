MangoPay.configure do |c|
  c.preproduction     = ENV['PCONF_MANGOPAY_PREPRODUCTION']
  c.client_id         = ENV['PCONF_MANGOPAY_CLIENT_ID']
  c.client_passphrase = ENV['PCONF_MANGOPAY_CLIENT_PASSPHRASE']
end