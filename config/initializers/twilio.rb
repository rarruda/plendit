
# initialize twilio client:
TWILIO_CLIENT = Twilio::REST::Client.new(ENV['PCONF_TWILIO_ACCOUNT_SID'], ENV['PCONF_TWILIO_AUTH_TOKEN'])
