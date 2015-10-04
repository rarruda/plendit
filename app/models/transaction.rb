class Transaction < ActiveRecord::Base
  has_paper_trail


  belongs_to :booking

  #has_one :from_user
  #has_one :to_user

  enum category: { payin_preauth: 1, payin_capture: 2, transfer_to_renter: 3, refund_transfer_to_renter: 5, payout_to_bank_account: 10 }
  enum status_v: { created: 0, succeded: 1, failed: 2 }

  enum src_type: { preauth_vid: 1, card_vid: 2, payin_wallet_vid: 3 }
  enum dst_type: { payout_wallet_vid: 6, bank_account_vid: 7 } #if refund: {card_vid: 2, payin_wallet_vid: 3}

  enum transaction_type: { t_preauth_vid: 1, t_payin_vid: 2, t_transfer_vid: 3, t_payout_vid: 4 }
end
