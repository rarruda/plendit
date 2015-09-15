class MangopayWebhook < ActiveRecord::Base
  enum status: { received: 0 }
end
