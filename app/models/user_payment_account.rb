class UserPaymentAccount < ActiveRecord::Base
  has_paper_trail

  belongs_to :user

  before_validation :normalize_bank_account_number
  before_validation :set_bank_account_iban

  validates :user_id, presence: true
  validates :bank_account_number, uniqueness: {message: "(account number) is in use by another user in plendit."}
  validate  :is_bank_account_number_valid?
  validate  :is_bank_account_iban_valid?



  private
  def set_bank_account_iban
    self.bank_account_iban = Ibanizator.new.calculate_iban country_code: PLENDIT_COUNTRY_CODE, account_number: self.bank_account_number
  end

  # only valid for norway:
  def is_bank_account_number_valid?
    # check a regex to see if its a 11 digit number
    errors.add(:bank_account_number, "invalid account number (only numbers, 11 digits)") if self.bank_account_number !~ /\A[0-9]{11}\z/
    # remove check_digit, calculate Mod11, and see if it still matches:
    errors.add(:bank_account_number, "invalid account number (wrong checksum)") if ( Mod11.new( self.bank_account_number[0..-2] ).full_value != self.bank_account_number )
  end

  def is_bank_account_iban_valid?
    errors.add(:bank_account_iban, "generated iban account number is invalid") if not Ibanizator.iban_from_string(self.bank_account_iban).valid?
  end

  def normalize_bank_account_number
    self.bank_account_number.gsub!(/(\s|\.)+/, "")
  end

end
