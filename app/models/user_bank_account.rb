class UserBankAccount < ActiveRecord::Base
  belongs_to :user

  before_validation :normalize_account_number
  before_validation :set_iban

  validates :user_id, presence: true
  validates :account_number, uniqueness: {message: "(account number) is in use by another user in plendit."}
  validate  :is_account_number_valid?
  validate  :is_iban_valid?


  private
  def set_iban
    self.iban = Ibanizator.new.calculate_iban country_code: :no, account_number: self.account_number
  end

  # only valid for norway:
  def is_account_number_valid?
    # check a regex to see if its a 11 digit number
    errors.add(:account_number, "invalid account number (only numbers, 11 digits)") if self.account_number !~ /\A[0-9]{11}\z/
    # remove check_digit, calculate Mod11, and see if it still matches:
    errors.add(:account_number, "invalid account number (wrong checksum)") if ( Mod11.new( self.account_number[0..-2] ).full_value != self.account_number )
  end

  def is_iban_valid?
    errors.add(:iban, "generated iban account number is invalid") if Ibanizator.iban_from_string(self.iban).valid?
  end

  def normalize_account_number
    self.account_number.gsub!(/(\s|\.)+/, "")
  end
end
