class FinancialTransaction < ActiveRecord::Base
  include AASM
  include UniquelyIdentifiable

  # for mangopay callback urls:
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  has_paper_trail

  belongs_to :financial_transactionable, polymorphic: true

  # fields which doesnt make any sense to persist to the database:
  attr_accessor :secure_mode_redirect_url, :secure_mode_needed


  # Probably need a transfer_refund too.
  enum purpose:          { rental_with_deposit: 1, rental: 2, deposit: 3, insurance_other: 6, payout_to_user: 7, card_validation: 11 }
  enum transaction_type: { preauth: 1, payin: 2, transfer: 3, payout: 4, payin_refund: 12, transfer_refund: 13 }
  enum nature:           { normal: 0, refund: 10, repudiation: 11, settlement: 12 }
  enum state:    { pending: 1, processing: 2, finished: 5, errored: 10, unknown_state: 20 }
  #mangopay status:CREATED                    SUCCEEDED    FAILED
  enum src_type: { src_preauth_vid:      1, src_card_vid:          2, src_payin_wallet_vid: 3, src_payout_wallet_vid: 6, src_payin_vid: 8 }
  enum dst_type: { dst_payin_wallet_vid: 3, dst_payout_wallet_vid: 6, dst_bank_account_vid: 7, dst_payin_transaction_vid: 9 } #if refund: {dst_card_vid: 2}

  enum preauth_payment_status: { not_preauth: 0, preauth_waiting: 1, preauth_validated: 2, preauth_cancelled: 3, preauth_expired: 4 }


  before_validation :set_vids, if: :new_record?


  validates :transaction_type, presence: true, inclusion: { in: FinancialTransaction.transaction_types.keys }
  validates :src_type,         presence: true, inclusion: { in: FinancialTransaction.src_types.keys }
  validates :src_vid,          presence: true
  validates :dst_type,         presence: true, inclusion: { in: FinancialTransaction.dst_types.keys }, unless: Proc.new{ |ft| ft.preauth? || ft.payin_refund? }
  validates :dst_vid,          presence: true,                                       unless: Proc.new{ |ft| ft.preauth? || ft.payin_refund? }
  validates :fees,             presence: true, numericality: { only_integer: true }, unless: :payin_refund?
  validates :amount,           presence: true, numericality: { only_integer: true }, unless: :payin_refund?
  validates :amount,           presence: true, numericality: { greater_than_or_equal_to: Rails.configuration.x.platform.payout_fee_amount }, if: :payout?

  # default cronological ordering:
  default_scope      { order(id: :desc) }

  # by transaction type:
  scope :preauth,    -> { where( transaction_type: FinancialTransaction.transaction_types[:preauth]  ) }
  scope :payin,      -> { where( transaction_type: FinancialTransaction.transaction_types[:payin]    ) }
  scope :transfer,   -> { where( transaction_type: FinancialTransaction.transaction_types[:transfer] ) }
  scope :payout,     -> { where( transaction_type: FinancialTransaction.transaction_types[:payout]   ) }
  scope :payin_refund,->{ where( transaction_type: FinancialTransaction.transaction_types[:payin_refund] ) }
  scope :transfer_refund,
                     -> { where( transaction_type: FinancialTransaction.transaction_types[:transfer_refund] ) }

  # by purpose:
  scope :rental_with_deposit,
                     -> { where( purpose: FinancialTransaction.purposes[:rental_with_deposit]  ) }
  scope :rental,     -> { where( purpose: FinancialTransaction.purposes[:rental]  ) }
  scope :deposit,    -> { where( purpose: FinancialTransaction.purposes[:deposit]  ) }
  scope :payout_to_user,
                     -> { where( purpose: FinancialTransaction.purposes[:payout_to_user]  ) }


  # by state/status:
  scope :pending,    -> { where( state: FinancialTransaction.states[:pending] ) }
  scope :errored,    -> { where( state: FinancialTransaction.states[:errored] ) }
  scope :finished,   -> { where( state: FinancialTransaction.states[:finished] ) }
  scope :pending_or_processing,
                     -> { where( state: [ FinancialTransaction.states[:pending], FinancialTransaction.states[:processing] ] ) }
  scope :processing_or_finished,
                     -> { where( state: [ FinancialTransaction.states[:processing], FinancialTransaction.states[:finished] ] ) }
  scope :errored_or_unknown_state,
                     -> { where( state: [ FinancialTransaction.states[:errored], FinancialTransaction.states[:unknown_state] ] ) }


  # by user: (complex...)
  # from_user: impacts payin account
  scope :from_user,  ->(user_id) { where( "( src_type = ? AND src_vid = ?) OR (dst_type = ? AND dst_vid = ? )",
      FinancialTransaction.src_types[:src_payin_wallet_vid], User.find(user_id).payin_wallet_vid,
      FinancialTransaction.dst_types[:dst_payin_wallet_vid], User.find(user_id).payin_wallet_vid,
    )
  }
  # to_user: impacts payout account
  scope :to_user,    ->(user_id) { where( "( src_type = ? AND src_vid = ?) OR (dst_type = ? AND dst_vid = ? )",
      FinancialTransaction.src_types[:src_payout_wallet_vid], User.find(user_id).payout_wallet_vid,
      FinancialTransaction.dst_types[:dst_payout_wallet_vid], User.find(user_id).payout_wallet_vid,
    )
  }

  aasm column: 'state' do
    state :pending, initial: true
    state :processing
    state :finished
    state :errored
    state :unknown_state


    after_all_transitions :log_status_change

    event :process, after: :process_on_mangopay do
      transitions from: :pending, to: :processing
    end

    event :finish do
      transitions from: :processing, to: :finished
    end

    event :fail do
      transitions from: [:pending,:processing,:finished], to: :errored
    end

    event :set_unknown_state do
      transitions from: [:pending,:processing,:finished], to: :unknown_state
    end
  end

  def to_param
    self.guid
  end

  def log_status_change
    LOG.info message: "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event}) for financial_transaction_id: #{self.id}",
      financial_transaction_id: self.id
  end

  def from_user_id
    case self.src_type
    when 'src_preauth_vid'
      nil
    when 'src_card_vid'
      UserPaymentCard.find_by(card_vid: self.src_vid).user_id
    when 'src_payin_wallet_vid'
      User.find_by(payin_wallet_vid: self.src_vid).id
    when 'src_payout_wallet_vid'
      User.find_by(payout_wallet_vid: self.src_vid).id
    end
  end

  def to_user_id
    case self.dst_type
    when 'dst_payin_wallet_vid'
      User.find_by(payin_wallet_vid: self.dst_vid).id
    when 'dst_payout_wallet_vid'
      User.find_by(payout_wallet_vid: self.dst_vid).id
    when 'dst_bank_account_vid'
      UserPaymentAccount.find_by(bank_account_vid: self.dst_vid).user_id
    when 'dst_payin_transaction_vid'
      User.find_by(payin_wallet_vid: self.dst_vid).id
    end
  end

  def amount_to_receive
    return nil if amount.nil?

    self.amount - ( self.fees || 0 )
  end

  def payin_wallet_direction_for_user
    if self.preauth? ||
      self.payin? ||
      ( self.transfer? && self.dst_payin_wallet_vid? )
      :in
    else
      :out
    end
  end

  def payout_wallet_direction_for_user
    if ( self.transfer? && self.dst_payout_wallet_vid? )
      :in
    elsif self.payout?
      :out
    else
      :out
    end
  end

  # triggered on process! (state: pending => processing)
  def process_on_mangopay
    case self.transaction_type.to_sym
    when :preauth
      do_preauth
      # dont quite finish, as requires some refreshes until we know that it went through. (all the way to validated)
    when :payin
      do_payin
    when :transfer
      do_transfer
    when :payout
      do_payout
      # dont quite finish, as requires some refreshes until we know that it went through. (all the way to finished)
    when :payin_refund
      # this should create a refund for a specific financial_transaction of transaction_type payin
      do_payin_refund
    else
      LOG.error message: "Could not handle transaction. Unprocessable transaction_type", financial_transaction_id: self.id
      self.fail!
    end
  end



  # triggered externally
  # THIS TRIGGERS A SLOW API CALL!
  def process_cancel_preauth!
    if self.transaction_type.to_sym == :preauth
      do_preauth_cancel
    else
      LOG.error message: "Cannot cancel this type of transaction", financial_transaction_id: self.id, transaction_type: self.transaction_type
      raise "Cannot cancel this type of transaction on this status"
    end
  end

  # triggered externally (job? refresh_financial_transactions?)
  def process_refresh!
    case self.transaction_type.to_sym
    when :preauth
      do_preauth_refresh
    when :payout
      do_payout_refresh
    when :payin_refund
      do_refund_refresh
    when :payin
      do_payin_refresh
    else
      LOG.error message: "Cannot refresh this type of transaction", financial_transaction_id: self.id, transaction_type: self.transaction_type
      raise "Cannot refresh this type of transaction"
    end
  end

  def from_user
    case self.financial_transactionable_type
    when 'Booking'
      self.financial_transactionable.from_user
    when 'UserPaymentCard'
      self.financial_transactionable.user
    else
      nil
    end
  end

  def for_booking
    if self.financial_transactionable_type == 'Booking'
      Booking.find( self.financial_transactionable_id )
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
    card = self.from_user.user_payment_cards.find_by( card_vid: self.src_vid )
    raise "card does not belong to requester" if card.nil?

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb
      preauth_tag = case self.financial_transactionable_type
      when 'Booking'
        "booking_id=#{financial_transactionable_id} #{self.purpose}"
      when 'UserPaymentCard'
        "user_payment_card_id=#{financial_transactionable_id} #{self.purpose}"
      end
      preauth = MangoPay::PreAuthorization.create(
        {
          'Tag'          => preauth_tag,
          'AuthorId'     => self.from_user.payment_provider_vid,
          'CardId'       => self.src_vid,
          'DebitedFunds' => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.amount
          },
          'SecureMode'   => require_secure_mode? ? 'FORCE' : 'DEFAULT',
          'SecureModeReturnURL' => booking_url( self.financial_transactionable.guid, callback: true ),
        },
        self.guid,
      )
      self.update(
        transaction_vid: preauth['Id'],
        result_code:     preauth['ResultCode'],
        result_message:  preauth['ResultMessage'],
        response_body:   preauth
      )

      self.secure_mode_redirect_url = preauth['SecureModeRedirectURL']
      self.secure_mode_needed       = preauth['SecureModeNeeded']

      # set payment status from preauth's point of view: (WAITING, CANCELED, EXPIRED, VALIDATED)
      set_preauth_payment_status preauth['PaymentStatus']

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status preauth['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: preauth
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction, left in processing state", financial_transaction_id: self.id, mangopay_result: preauth
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
      preauth = MangoPay::PreAuthorization.fetch( self.transaction_vid )

      self.update(
        result_code:     preauth['ResultCode'],
        result_message:  preauth['ResultMessage'],
        response_body:   preauth
      )

      # set payment status from preauth's point of view: (WAITING, CANCELED, EXPIRED, VALIDATED)
      set_preauth_payment_status preauth['PaymentStatus']

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status preauth['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: preauth
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: preauth
    end
  end

  # called from process_cancel_preauth
  def do_preauth_cancel
    #sanity check
    unless self.preauth?         &&
      self.src_card_vid?         &&
      #self.dst_payin_wallet_vid? &&#dst_payin_transaction_vid
      ( self.finished? || self.processing? ) &&
      ( ['Booking', 'UserPaymentCard'].include? self.financial_transactionable_type ) &&
      self.financial_transactionable_id.present?

      raise "can not cancel this preauth transaction with this method"
    end

    begin
      # https://docs.mangopay.com/api-references/card/pre-authorization/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pre_authorization.rb#L5
      cancelation = MangoPay::PreAuthorization.update(
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
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: cancelation
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: cancelation
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

      # https://docs.mangopay.com/api-references/idempotency-support/
      payin = MangoPay::PayIn::PreAuthorized::Direct.create(
        {
          'Tag'                => "booking_id=#{self.financial_transactionable_id} #{self.purpose}",
          'AuthorId'           => self.financial_transactionable.from_user.payment_provider_vid,
          'PreauthorizationId' => self.src_vid,
          'CreditedWalletId'   => self.dst_vid,
          'DebitedFunds'   => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.amount
            },
          'Fees'           => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => 0
            },
          'SecureModeReturnURL' => booking_url( self.financial_transactionable.guid ),
        },
        nil, # filter = nil
        self.guid,
      )

      self.update(
        transaction_vid: payin['Id'],
        result_code:     payin['ResultCode'],
        result_message:  payin['ResultMessage'],
        response_body:   payin
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status payin['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payin
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payin
      self.fail!
    end
  end

  # NOTE: not currently part of any payment flow: (aka: not in use)
  # called from process_refresh
  def do_payin_refresh
    #sanity check
    unless self.payin? &&
      self.processing?

      raise "can not process this transaction with this method from this state"
    end

    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payin = MangoPay::PayIn.fetch( self.transaction_vid )
      self.update(
        result_code:     payin['ResultCode'],
        result_message:  payin['ResultMessage'],
        response_body:   payin,
      )
      # consider adding more sanity checking, and raise exception if local data does not match with remote?

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status payin['Status']
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payin
    end
  end

  # called from process_on_mangopay
  def do_payin_refund
    #sanity check
    unless self.payin_refund?   &&
      self.src_payin_vid?       &&
      #self.dst_payin_wallet_vid?  &&
      self.financial_transactionable_type == 'Booking'  &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end

    if self.amount < 1_00
      self.errored!
      raise "refunds are only available for values greater then 1 EUR"
    end

    begin
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/http_calls.rb#L70
      # https://docs.mangopay.com/api-references/refund/%E2%80%A2-refund-a-pay-in/
      payin_refund = MangoPay::PayIn.refund( self.src_vid,
        {
          'Tag'     => "booking_id=#{self.financial_transactionable_id} #{self.purpose}",
          'AuthorId' => self.financial_transactionable.from_user.payment_provider_vid,
          'DebitedFunds'   => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.amount
          },
          'Fees'           => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => 0
          },
        }
      )

      self.update(
        transaction_vid: payin_refund['Id'],
        result_code:     payin_refund['ResultCode'],
        result_message:  payin_refund['ResultMessage'],
        amount:          payin_refund['CreditedFunds']['Amount'],
        fees:            payin_refund['Fees']['Amount'],
        response_body:   payin_refund
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status payin_refund['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payin_refund
    rescue => e
      self.fail!
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payin_refund
    end
  end

  # called from process_refresh
  def do_refund_refresh
    #sanity check
    unless self.payin_refund? &&
      self.processing?

      raise "can not process this transaction with this method from this state"
    end

    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      refund = MangoPay::Refund.fetch( self.transaction_vid )
      self.update(
        amount:          refund['CreditedFunds']['Amount'],
        fees:            refund['Fees']['Amount'],
        result_code:     refund['ResultCode'],
        result_message:  refund['ResultMessage'],
        response_body:   refund,
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status refund['Status']
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: refund
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

      # https://docs.mangopay.com/api-references/idempotency-support/
      transfer = MangoPay::Transfer.create(
        {
          'Tag'              => "booking_id=#{financial_transactionable_id} #{self.purpose}",
          'AuthorId'         => self.financial_transactionable.from_user.payment_provider_vid, #owner of the debitedWalletId
          'CreditedUserId'   => self.financial_transactionable.user.payment_provider_vid,
          'DebitedWalletId'  => self.src_vid,
          'CreditedWalletId' => self.dst_vid,
          'DebitedFunds'     => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.amount #platform_fee_with_insurance is removed in Fees.
          },
          'Fees' => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.fees
          },
        },
        nil,
        self.guid,
      )

      self.update(
        transaction_vid: transfer['Id'],
        result_code:     transfer['ResultCode'],
        result_message:  transfer['ResultMessage'],
        response_body:   transfer
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status transfer['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: transfer
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: transfer
    end
  end

  # called from process_on_mangopay
  def do_payout
    #sanity check
    unless self.payout? &&
      self.src_payout_wallet_vid?        &&
      self.dst_bank_account_vid?         &&
      self.financial_transactionable_type == 'UserPaymentAccount' &&
      self.financial_transactionable_id.present?

      raise "can not process this transaction with this method"
    end
    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payout = MangoPay::PayOut::BankWire.create(
        {
          'Tag'            => "user_id=#{self.financial_transactionable.user_id}", # No need for: #{self.purpose}
          'AuthorId'       => self.financial_transactionable.user.payment_provider_vid,
          'CreditedUserId' => self.financial_transactionable.user.payment_provider_vid, # Note: CreditedUserId And AuthorId must always be the same value!
          'DebitedFunds'   => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.amount
            },
          'Fees' => {
            'Currency' => PLENDIT_CURRENCY_CODE,
            'Amount'   => self.fees
            },
          'DebitedWalletId'  => self.financial_transactionable.user.payout_wallet_vid,
          'BankAccountId'    => self.financial_transactionable.bank_account_vid,
          'BankWireRef'      => "ref: #{self.guid[0..6]}",
        },
        # nil,
        # self.guid,
      )
      self.update(
        transaction_vid: payout['Id'],
        result_code:     payout['ResultCode'],
        result_message:  payout['ResultMessage'],
        response_body:   payout
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status payout['Status']

    rescue MangoPay::ResponseError => e
      self.update_attributes(response_body: e.message)
      self.fail!
      LOG.error message: "MangoPay::ResponseError Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payout
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payout
    end
  end

  # called from process_refresh
  def do_payout_refresh
    #sanity check
    unless self.payout? &&
      self.processing?

      raise "can not process this transaction with this method from this state"
    end

    begin
      # https://docs.mangopay.com/api-references/pay-out-bank-wire/
      # https://github.com/Mangopay/mangopay2-ruby-sdk/blob/master/lib/mangopay/pay_out.rb
      payout = MangoPay::PayOut.fetch( self.transaction_vid )
      self.update(
        result_code:     payout['ResultCode'],
        result_message:  payout['ResultMessage'],
        response_body:   payout
      )

      # update transaction status from mangopay result: (one of: CREATED, SUCCEEDED, FAILED)
      aasm_change_on_status payout['Status']
    rescue => e
      LOG.error message: "Exception e:#{e} processing transaction", financial_transaction_id: self.id, mangopay_result: payout
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
      LOG.info message: "Staying put in my current state", financial_transaction_id: self.id, state: state
    else
      #unknown state
      self.set_unknown_state!
      LOG.error message: "unknown status result", financial_transaction_id: self.id, state: state
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
      LOG.error message: "unknown payment_status result from PayIn::PreAuthorization::Update.fetch: #{payment_status}", financial_transaction_id: self.id
    end
  end

  def require_secure_mode?
    self.amount >= Plendit::Application.config.x.platform.require_secure_mode_after_amount
  end

  # set vids given that we have a financial_transactionable_type, financial_transactionable_id and transaction_type
  def set_vids
    self.attributes = case self.transaction_type.to_sym
    when :preauth
      # info comes from booking

      src_vid = case self.financial_transactionable_type
      when 'Booking'
        self.financial_transactionable.user_payment_card.card_vid
      when 'UserPaymentCard'
        self.financial_transactionable.card_vid
      else
        nil
      end

      {
        src_type: :src_card_vid,
        src_vid:  src_vid,
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
        #src_vid: #... needs to be specified... cannot be set here.
        dst_type: :dst_payin_wallet_vid,
        dst_vid:  self.financial_transactionable.from_user.payin_wallet_vid
      }
    when :payin_refund
      # no need to set dst_type/dst_vid
      {
        src_type: :src_payin_vid,
        #src_vid: #... needs to be specified... cannot be set here.
        dst_type: nil,
        dst_vid:  nil
      }
    when :transfer
      # info comes from booking
      {
        src_type: :src_payin_wallet_vid,
        src_vid:  self.financial_transactionable.from_user.payin_wallet_vid,
        dst_type: :dst_payout_wallet_vid,
        dst_vid:  self.financial_transactionable.user.payout_wallet_vid
      }
    when :payout
      # info comes from user_payment_card
      {
        src_type: :src_payout_wallet_vid,
        src_vid:  self.financial_transactionable.user.payout_wallet_vid,
        dst_type: :dst_bank_account_vid,
        dst_vid:  self.financial_transactionable.bank_account_vid
      }
    else
      LOG.error message: "error, unidentified transaction_type", financial_transaction_id: self.id
      raise "error, unidentified transaction_type"
    end
  end

end
