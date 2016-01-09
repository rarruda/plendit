MangoPay.configure do |c|
  c.preproduction     = ENV['PCONF_MANGOPAY_PREPRODUCTION'] == "false" ? false : true
  c.client_id         = ENV['PCONF_MANGOPAY_CLIENT_ID']
  c.client_passphrase = ENV['PCONF_MANGOPAY_CLIENT_PASSPHRASE']
end

MANGOPAY_PRE_REGISTERED_CARD_TTL = 1800
MANGOPAY_CURRENCY_CODE           = 'NOK' #duplicate of PLENDIT_CURRENCY_CODE
MANGOPAY_DEFAULT_CARD_TYPE       = 'CB_VISA_MASTERCARD'
MANGOPAY_CARD_VALIDATION_AMOUNT  = 10_00 #how much to pre-authorize in a card to verify its validity.

# Config for creating callback urls:
#PCONF_MANGOPAY_CALLBACK_BASE_URL = ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL']

MANGOPAY_API_BASE_URL = Rails.env.production? ? 'https://api.mangopay.com' : 'https://api.sandbox.mangopay.com'
