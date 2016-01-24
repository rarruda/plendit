class MangopayWebhook < ActiveRecord::Base
  enum status:        { received: 0, finished: 2 } #ignored: 1 ?
  enum resource_type: { kyc: 1, payin: 2, transfer: 3, payout: 4, dispute: 9, other_resource: 10}

  before_save :set_resource_type, on: :create
  before_save :resource_refresh,  on: :create

  # https://docs.mangopay.com/api-references/events/

  private
  def set_resource_type
    event_type_first = event_type.split('_').first.downcase

    self.resource_type = ( MangopayWebhook.resource_types.keys.include? event_type_first ) ? event_type_first : 'other_resource'
  end


  def resource_refresh
    LOG.info message: "callback received: #{event_type} resource_vid:#{self.resource_vid}"

    case resource_type
    when 'kyc'

      LOG.info message: "KYC callback: nothing to do"
    when 'payin', 'transfer'
      # FIXME: payin_refund should be refreshed....

      LOG.info message: "Callback handling is yet in place for this event_type"
      #ft = FinancialTransaction.find_by_transaction_vid(self.resource_vid)
      #ft.process_refresh!

      #ft.financial_transactionable.refresh! if ft.financial_transactionable_type == 'Booking'
    when 'payout'
      ft = FinancialTransaction.find_by_transaction_vid(self.resource_vid)
      ft.process_refresh!
    else
      LOG.info message: "UNKNOWN RESOURCE callback (#{event_type}/#{resource_type}): nothing to do"
    end

    # mark event as finished!
    self.status = 'finished'
  end
end
