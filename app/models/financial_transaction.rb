class FinancialTransaction < ActiveRecord::Base
  include AASM

  # for mangopay callback urls:
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  has_paper_trail

  belongs_to :financial_transactionable, polymorphic: true

  #has_one :from_user #?
  #has_one :to_user   #?


  enum transaction_type: { preauth: 1, payin: 2, transfer: 3, payout: 4 }
  enum nature:           { normal: 0, refund: 10, repudiation:11, settlement: 12 }

  enum state:    { pending: 1, processing: 2, finished: 5, errored: 10, unknown_state: 20 }
  #mangopay status:CREATED                    SUCCEEDED    FAILED
  enum src_type: { src_preauth_vid:      1, src_card_vid:          2, src_payin_wallet_vid: 3, src_payout_wallet_vid: 6 }
  enum dst_type: { dst_payin_wallet_vid: 3, dst_payout_wallet_vid: 6, dst_bank_account_vid: 7, dst_payin_transaction_vid: 9 } #if refund: {dst_card_vid: 2}

  enum preauth_payment_status: { not_preauth: 0, preauth_waiting: 1, preauth_validated: 2, preauth_cancelled: 3, preauth_expired: 4 }


  before_validation :set_guid, :on => :create
  before_validation :set_vids, :on => :create


  validates :guid,             uniqueness: true
  validates :transaction_type, presence: true, inclusion: { in: FinancialTransaction.transaction_types.keys }
  validates :src_type,         presence: true, inclusion: { in: FinancialTransaction.src_types.keys }
  validates :src_vid,          presence: true
  validates :dst_type,         presence: true, inclusion: { in: FinancialTransaction.dst_types.keys }, unless: "self.preauth?"
  validates :dst_vid,          presence: true, unless: "self.preauth?"
  validates :amount,           presence: true, numericality: { only_integer: true }
  validates :fees,             presence: true, numericality: { only_integer: true }


  # by transaction type:
  scope :preauth,    -> { where( transaction_type: FinancialTransaction.transaction_types[:preauth]  ) }
  scope :payin,      -> { where( transaction_type: FinancialTransaction.transaction_types[:payin]    ) }
  scope :transfer,   -> { where( transaction_type: FinancialTransaction.transaction_types[:transfer] ) }
  scope :payout,     -> { where( transaction_type: FinancialTransaction.transaction_types[:payout]   ) }

  # by state/status:
  scope :pending_or_processing,
                     -> { where( state: [ FinancialTransaction.transaction_types[:pending], FinancialTransaction.transaction_types[:processing] ] ) }
  scope :finished,   -> { where( state: FinancialTransaction.transaction_types[:finished] ) }

  # by user: (complex...)
  #scope :from_user(user_id) -> { where() } #use src_vid for fast/reliable lookups
  #scope :to_user(user_id)   -> { where() } #use dst_vid for fast/reliable lookups

  aasm column: 'state' do
    state :pending, initial: true
    state :processing
    state :finished
    state :errored
    state :unknown_state

    event :process, after: :process_on_mangopay do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: :processing, to: :errored
    end

    # possible only for transaction_type: preauth
    #event :cancel, after: :process_cancel do
    #  transitions from: :finished, to: :cancelled do
    #    guard { self.preauth? }
    #  end
    #end
  end

  def to_param
    self.guid
  end



  # triggered on process! (state: pending => processing)
  def process_on_mangopay
    case self.transaction_type.to_sym
    when :preauth
      do_preauth
      # dont quite finish, as requires some refreshes until we know that it went through. (all the way to validated)
    when :payin
      do_payin
      self.finish!
    when :transfer
      do_transfer
      self.finish!
    when :payout
      do_payout
      # not finished quite yet, requires some refreshes until we know that it went through.
      # so left as processing. refresh_from_mangopay should move this forward.
    else
      LOG.error "Could not handle transaction. Unprocessable transaction_type", { transaction_id: self.id }
      self.fail!
    end
  end


  # def refresh_from_mangopay
  # end

  # triggered externally
  def process_cancel_preauth!
    if self.transaction_type.to_sym == :preauth
      self.do_preauth_cancel
    else
      raise "Cannot cancel this type of transaction", { transaction_id: self.id, transaction_type: self.transaction_type }
    end
  end

  # triggered externally
  def process_refresh!
    case self.transaction_type.to_sym
    when :preauth
      self.do_preauth_refresh
    when :payout
      self.do_payout_refresh
    else
      raise "Cannot refresh this type of transaction", { transaction_id: self.id, transaction_type: self.transaction_type }
    end
  end

  private

  # called from process_on_mangopay
  def do_preauth
    #sanity check
    unless self.preauth?         &&
      self.src_card_vid?         &&
      #self.dst_payin_transaction_vid? &&#
      ( ['Booking', 'UserPaymentCard'].include? self.financial_transactionable_type ) &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end

    # sanity check: preauth card belongs to correct user:
    card = self.financial_transactionable.from_user.user_payment_cards.find_by( card_vid: self.src_vid )
    raise "card does not belong to requester" if card.nil?

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb
      preauth = MangoPay::PreAuthorization.create(
        'Tag'          => "booking_id=#{financial_transactionable_id}", #from_user_id= to_user_id
        'AuthorId'     => self.financial_transactionable.from_user.payment_provider_vid,
        'CardId'       => self.src_vid,
        'DebitedFunds' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => self.amount
        },
        'SecureMode'   => 'DEFAULT',
        'SecureModeReturnURL' => booking_url( self.financial_transactionable.guid ),
      )
      self.update(
        transaction_vid: preauth['Id'],
        result_code:     preauth['ResultCode'],
        result_message:  preauth['ResultMessage'],
        response_body:   preauth
      )

      set_preauth_payment_status preauth['PaymentStatus']

      # update transaction status:
      aasm_change_on_status preauth['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: preauth }
      self.fail!
    rescue => e
      LOG.error "Exception e:#{e} processing transaction, left in processing state", { transaction_id: self.id, mangopay_result: preauth }
    end
  end

  # called from process_refresh
  def do_preauth_refresh
    #sanity check
    unless self.preauth?         &&
      self.src_card_vid?         &&
      #self.dst_payin_wallet_vid? &&#dst_payin_transaction_vid
      #self.finished?             &&
      ( ['Booking', 'UserPaymentCard'].include? self.financial_transactionable_type ) &&
      self.financial_transactionable_id.present?

      raise "can not refresh this preauth transaction with this method"
    end

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb#L5
      preauth = MangoPay::PayIn::PreAuthorization.fetch( self.transaction_vid )

      self.update(
        result_code:     preauth['ResultCode'],
        result_message:  preauth['ResultMessage'],
        response_body:   preauth
      )

      set_preauth_payment_status preauth['PaymentStatus']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: preauth }
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: preauth }
    end
  end

  # called from process_cancel_preauth
  def do_preauth_cancel
    #sanity check
    unless self.preauth?         &&
      self.src_card_vid?         &&
      #self.dst_payin_wallet_vid? &&#dst_payin_transaction_vid
      self.finished?             &&
      ( ['Booking', 'UserPaymentCard'].include? self.financial_transactionable_type ) &&
      self.financial_transactionable_id.present?

      raise "can not cancel this preauth transaction with this method"
    end

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb#L5
      cancelation = MangoPay::PayIn::PreAuthorization.update(
        self.transaction_vid,
        { 'PaymentStatus' => 'CANCELED' }
      )

      self.update(
        result_code:     cancelation['ResultCode'],
        result_message:  cancelation['ResultMessage'],
        response_body:   cancelation
      )

      set_preauth_payment_status cancelation['PaymentStatus']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: cancelation }
      self.fail!
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: cancelation }
    end
  end

  # called from process_on_mangopay
  def do_payin
    #sanity check
    unless self.payin?            &&
      self.src_preauth_vid?       &&
      self.dst_payin_wallet_vid?  &&
      self.financial_transactionable_type == 'Booking'  &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end

    begin
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_in.rb#L30
      # https://docs.mangopay.com/api-references/payins/preauthorized-payin/
      payin = MangoPay::PayIn::PreAuthorized::Direct.create(
        'Tag'                => "booking_id=#{self.financial_transactionable_id}",
        'AuthorId'           => self.financial_transactionable.from_user.payment_provider_vid,
        'CreditedUserId'     => self.financial_transactionable.from_user.payment_provider_vid,
        'PreauthorizationId' => 'DIRECT',
        'PreauthorizationId' => self.financial_transactionable.last_preauthorization_vid, #FOOBAR
        'CreditedWalletId'   => self.dst_vid,
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => self.amount
          },
        'Fees'           => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => 0
          },
        'SecureModeReturnURL' => booking_url( self.financial_transactionable.guid )
      )

      self.update(
        transaction_vid: payin['Id'],
        result_code:     payin['ResultCode'],
        result_message:  payin['ResultMessage'],
        response_body:   payin
      )

      # update transaction status:
      aasm_change_on_status payin['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: payin }
      self.fail!
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: payin }
    end
  end

  # called from process_on_mangopay
  def do_transfer
    #sanity check
    unless self.transfer?         &&
      self.src_payin_wallet_vid?  &&
      self.dst_payout_wallet_vid? &&
      self.financial_transactionable_type == 'Booking'  &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end
    begin
      # https://docs.mangopay.com/api-references/transfers/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/transfer.rb
      transfer = MangoPay::Transfer.create(
        'Tag'            => "booking_id=#{financial_transactionable_id}",
        'AuthorId'       => self.financial_transactionable.user.payment_provider_vid,
        'CreditedUserId' => self.financial_transactionable.user.payment_provider_vid, # Note: CreditedUserId And AuthorId must always be the same value!
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => self.amount #platform_fee_with_insurance is removed in Fees.
        },
        'Fees' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => self.fees
        },
        'DebitedWalletId'  => self.src_vid,
        'CreditedWalletId' => self.dst_vid
      )

      self.update(
        transaction_vid: transfer['Id'],
        result_code:     transfer['ResultCode'],
        result_message:  transfer['ResultMessage'],
        response_body:   transfer
      )

      # update transaction status:
      aasm_change_on_status transfer['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: transfer }
      self.fail!
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: transfer }
    end
  end

  # called from process_on_mangopay
  def do_payout
    #sanity check
    unless self.transaction_type.payout? &&
      self.src_payout_wallet_vid?        &&
      self.dst_bank_account_vid?         &&
      self.financial_transactionable_type == 'UserPaymentAccount' &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end
    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payout = MangoPay::PayOut.create(
        'Tag'            => "user_id=#{self.financial_transactionable.user_id}",
        'AuthorId'       => self.financial_transactionable.user.payment_provider_vid,
        'CreditedUserId' => self.financial_transactionable.user.payment_provider_vid, # Note: CreditedUserId And AuthorId must always be the same value!
        'DebitedFunds'   => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => self.amount
          },
        'Fees' => {
          'Currency' => PLENDIT_CURRENCY_CODE,
          'Amount'   => payout_fee
          },
        'DebitedWalletId'  => self.financial_transactionable.user.payout_wallet_vid,
        'BankAccountId'    => self.financial_transactionable.bank_account_vid,
        'BankWireRef'      => "ref: #{self.guid[0..6]}"
      )
      self.update(
        transaction_vid: payout['Id'],
        result_code:     payout['ResultCode'],
        result_message:  payout['ResultMessage'],
        response_body:   payout
      )
      # note: no state transition, as its still in Status CREATED until: (according to mangopay docs:)
      # "In production environment BankWire PayOuts will have a CREATED status until they are treated by our compliance team"
    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error "MangoPay::ResponseError Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: payout }
      self.fail!
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: payout }
    end
  end

  # called from process_refresh
  def do_payout_refresh

    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payout = MangoPay::PayOut.fetch( self.transaction_vid )
      self.update(
        result_code:     payout['ResultCode'],
        result_message:  payout['ResultMessage'],
        response_body:   payout
      )

      # update transaction status:
      aasm_change_on_status payout['Status']
    rescue => e
      LOG.error "Exception e:#{e} processing transaction", { transaction_id: self.id, mangopay_result: payout }
    end
  end

  def aasm_change_on_status status
    case status
    when 'FAILED'
      self.fail!
    when 'SUCCEEDED'
      self.finish!
    when 'CREATED'
      #just stay at status processing.
      LOG.info "Staying put in my current state", { transaction_id: self.id, state: state }
    else
      #unknown status
      LOG.error "unknown status result from Payout.fetch", { transaction_id: self.id, mangopay_result: payout }
    end
  end

  def set_preauth_payment_status payment_status
    self.preauth_payment_status = case payment_status
    when 'WAITING'
      :preauth_waiting
    when 'CANCELED'
      :preauth_cancelled
    when 'EXPIRED'
      :preauth_expired
    when 'VALIDATED'
      :preauth_validated
    else
      LOG.error "unknown payment_status result from PayIn::PreAuthorization::Update.fetch", { transaction_id: self.id, mangopay_result: cancelation }
    end
  end

  # set vids given that we have a financial_transactionable_type, financial_transactionable_id and transaction_type
  def set_vids
    self.attributes = case self.transaction_type.to_sym
    when :preauth
      # info comes from booking
      {
        src_type: :src_card_vid,
        src_vid:  self.financial_transactionable.user_payment_card.card_vid,
        dst_type: nil, #:dst_payin_transaction_vid,
        dst_vid:  nil
      }
      # LATER:
      #dst_type will be dst_payin_transaction_vid
      #dst_vid  will be the transaction_vid of the payin transaction.
    when :payin
      # info comes from booking
      {
        src_type: :src_preauth_vid,
        #src_vid:  nil,# self.booking.transactions.preauth.where(preauth_payment_status: Transaction.preauth_payment_status[:preauth_validated]).limit(1).first?
                      #... or needs to be specified...
                      # FIXME
        dst_type: :dst_payin_wallet_vid,
        dst_vid:  self.financial_transactionable.from_user.payin_wallet_vid
      }
    when :transfer
      # info comes from booking
      {
        src_type: :src_payin_wallet_vid,
        src_vid:  self.from_user.payin_wallet_vid,
        dst_type: :dst_payout_wallet_vid,
        dst_vid:  self.user.payout_wallet_vid
      }
    when :payout
      # info comes from user_payment_card
      {
        src_type: :src_payout_wallet_vid,
        src_vid:  self.user_payment_card.user.payout_wallet_vid,
        dst_type: :dst_bank_account_vid,
        dst_vid:  self.user_payment_card.bank_account_vid
      }
    else
      LOG.error "error, unidentified transaction_type", { transaction_id: self.id }
      raise "error, unidentified transaction_type"
    end
  end

  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
