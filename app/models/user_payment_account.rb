class UserPaymentAccount < ActiveRecord::Base
  has_paper_trail

  belongs_to :user
  has_many   :financial_transactions, as: 'financial_transactionable'

  before_validation :normalize_bank_account_number, unless: 'bank_account_number.nil?'
  before_validation :set_bank_account_iban,         unless: 'bank_account_number.nil?'

  validates :user_id,             presence: true
  validates :bank_account_number, uniqueness: {message: "(account number) is in use by another user in plendit."}, unless: 'bank_account_number.nil?'
  validate  :is_bank_account_number_valid?, unless: 'bank_account_number.nil?'
  validate  :is_bank_account_iban_valid?,   unless: 'bank_account_number.nil?'
  validate  :user_is_provisioned

  # above validations, and before_validations should have a IF statement checking if bank_account is not nil?

  after_save :provision_with_mangopay,
    if: 'mangopay_provisionable?'

  def pretty_bank_account_number
    self.bank_account_number.scan(/(.{4})(.{2})(.{5})/).join(".")
  end


  def mangopay_provisionable?
    self.user_id.present? && self.user.mangopay_provisioned? && self.user.has_address?
  end

  def build_financial_transaction_payout amount = nil
    return nil if amount.blank?

    payout_fee = ( amount < Plendit::Application.config.x.platform.payout_fee_waived_after_amount ) ? Plendit::Application.config.x.platform.payout_fee_amount : 0

    {
      transaction_type: 'payout',
      amount: amount,
      fees:   payout_fee,
    }
  end

  def create_financial_transaction_payout amount = nil

    t = self.financial_transactions.create( self.build_financial_transaction_payout(amount) )
    t.process!
  end


  private
  def user_is_provisioned
    unless self.user_id.present? && self.user.mangopay_provisioned?
      errors.add(:base, "You are not yet provisioned with mangopay")
    end
  end

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

  def provision_with_mangopay
    # mangopay dont support de-provisioning of bank accounts...
    # But as we only support one bank account at a time that's possibly what we would have done with the previous bank account..
    # Sadly we can't even set a previously created bank_account as not active anymore.

    if self.bank_account_vid.blank?
      LOG.info "Provisioning bank account with Mangopay:", {user_id: self.user.id, bank_account_iban: self.bank_account_iban}
      begin
        # https://docs.mangopay.com/api-references/bank-accounts/
        bank_account = MangoPay::BankAccount.create( self.user.payment_provider_vid, {
          'Tag'          => "user_id=#{self.user_id}",
          'OwnerName'    => self.user.name,
          'Type'         => 'IBAN',
          'UserId'       => self.user.payment_provider_vid,
          'IBAN'         => self.bank_account_iban,
          'OwnerAddress' => {
            'AddressLine1' => self.user.home_address_line,
            'City'         => self.user.home_city,
            'PostalCode'   => self.user.home_post_code,
            'Country'      => self.user.country_of_residence
          }
        } )
        self.update_attributes( bank_account_vid: bank_account['Id'] )
      rescue => e
        LOG.error "Exception e:#{e} provisioning at mangopay the bank_account: #{bank_account}", {user_id: @user.id, user_payment_account_id: self.id, mangopay_result: bank_account }
        return nil
      end
    end
  end

end
