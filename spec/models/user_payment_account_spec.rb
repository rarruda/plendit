require 'rails_helper'

RSpec.describe UserPaymentAccount, type: :model do
  let(:account) {
    FactoryGirl.build_stubbed(
      :user_payment_account,
      user: FactoryGirl.build_stubbed(:user_a)
    )
  }

  it 'should accept a valid norwegian bank account number' do
    expect( account ).to be_valid
  end

  it 'should not accept a bank account number with an invalid account number' do
    account.bank_account_number = '15032080118'
    expect( account ).not_to be_valid
  end

  it 'should accept a norwegian bank account number with numbers and/or periods in it' do
    account.bank_account_number = '1503 20..80119'
    expect( account ).to be_valid
  end

  it 'should not accept a bank account number with the wrong number of digits' do
    account.bank_account_number = '150320801199999'
    expect( account ).not_to be_valid
  end

  it 'should not accept a bank account number with letters in it' do
    account.bank_account_number = '15032080foo'
    expect( account ).not_to be_valid
  end

  it 'should automatically generate an iban number from a bank account number' do
    account.bank_account_number = '15032080119'
    account.validate
    expect( account.bank_account_iban ).to be == "NO5015032080119"
  end

  it 'should not accept a bank account number without a user connected to it' do
    account.user_id = nil
    expect( account ).not_to be_valid
  end
end
