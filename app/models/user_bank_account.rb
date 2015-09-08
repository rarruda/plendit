class UserBankAccount < ActiveRecord::Base
  belongs_to :user

  before_validation :normalize_account_number
  before_validation :set_iban

  validates :account_number,
    uniqueness: true,
    length: { is: 11 },
    format: { with: /\A[0-9]{11}\z/,
      message: "only numbers, 11 digits" }

  validate :account_number,
    if: :is_account_number_valid?

  validates :user_id, presence: true
  validate :iban, if: :is_iban_valid?


  private
  def set_iban
    ibanizator = Ibanizator.new
    self.iban = ibanizator.calculate_iban country_code: :no, account_number: self.account_number
  end

  # only valid for norway:
  def is_account_number_valid?
    # remove check_digit, calculate Mod11, and see if it still matches:
    return false if self.account_number.length != 11
    Mod11.new( self.account_number[0..-2] ).full_value == self.account_number
  end

  def is_iban_valid?
    Ibanizator.iban_from_string(self.iban).valid?
  end

  def normalize_account_number
    self.account_number.gsub!(/(\s|\.)+/, "")
  end
end
