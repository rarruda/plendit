include Rails.application.routes.url_helpers

EVENT_TYPES = [
  'KYC_CREATED',
  'KYC_SUCCEEDED',
  'KYC_VALIDATION_ASKED',
  'KYC_FAILED',
  'PAYIN_NORMAL_CREATED',
  'PAYIN_NORMAL_SUCCEEDED',
  'PAYIN_NORMAL_FAILED',
  'PAYOUT_NORMAL_CREATED',
  'PAYOUT_NORMAL_SUCCEEDED',
  'PAYOUT_NORMAL_FAILED',
  'TRANSFER_NORMAL_CREATED',
  'TRANSFER_NORMAL_SUCCEEDED',
  'TRANSFER_NORMAL_FAILED',
  'PAYIN_REFUND_CREATED',
  'PAYIN_REFUND_SUCCEEDED',
  'PAYIN_REFUND_FAILED',
  'PAYOUT_REFUND_CREATED',
  'PAYOUT_REFUND_SUCCEEDED',
  'PAYOUT_REFUND_FAILED',
  'TRANSFER_REFUND_CREATED',
  'TRANSFER_REFUND_SUCCEEDED',
  'TRANSFER_REFUND_FAILED' ]


namespace :mangopay do
  namespace :webhooks do

    desc "Create mangopay webhooks to our app"
    task create: :environment do
      raise 'PCONF_MANGOPAY_CALLBACK_BASE_URL needs to be set' if ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL'].nil?

      EVENT_TYPES.each do |e|
        result = MangoPay::Hook.create(
          'Url'       => "#{ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL']}#{mangopay_callback_path}",
          'EventType' => e
        )

        puts result
      end
    end

    desc "Create mangopay webhooks to our app"
    task update: :environment do
      raise 'PCONF_MANGOPAY_CALLBACK_BASE_URL needs to be set' if ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL'].nil?

      hooks = MangoPay::Hook.fetch()

      pp hooks

      hooks.each do |h|
        result = MangoPay::Hook.update( h['Id'],
          'Url'    => "#{ENV['PCONF_MANGOPAY_CALLBACK_BASE_URL']}#{mangopay_callback_path}",
          'Status' => 'ENABLED',
          #'Tag'    => 'foobar',
        )

        pp result
      end

    end

    desc "List mangopay webhooks to our app"
    task list: :environment do
      puts MangoPay::Hook.fetch()
    end

  end
end

