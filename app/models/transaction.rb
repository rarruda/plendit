class Transaction < ActiveRecord::Base
  has_paper_trail

  belongs_to :booking

  #has_one :from_user
  #has_one :to_user
  #has_one :to_bank_account


  validates_uniqueness_of :guid


  before_validation :set_guid, :on => :create


  enum category:  { payin_preauth: 1, payin_capture: 2, transfer_to_renter: 3, refund_transfer_to_renter: 5, payout_to_bank_account: 10 }

  enum status_mp: { created: 0, succeded: 1, failed: 2 }

  enum src_type: { src_preauth_vid:      1, src_card_vid:          2, src_payin_wallet_vid: 3 }
  enum dst_type: { dst_payin_wallet_vid: 3, dst_payout_wallet_vid: 6, dst_bank_account_vid: 7 } #if refund: {card_vid: 2, payin_wallet_vid: 3}

  enum transaction_type: { preauth: 1, payin: 2, transfer: 3, payout: 4, refund: 5 }


  #scope :preauth,     -> { where( transaction_type: 'preauth' ) }
  scope :preauth,     -> { where( transaction_type: Transaction.transaction_types[:preauth] ) }



  def to_param
    self.guid
  end

  private

  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
