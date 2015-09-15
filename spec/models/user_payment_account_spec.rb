require 'rails_helper'

RSpec.describe UserPaymentAccount, type: :model do

  it 'should accept a valid norwegian bank account number' do
    expect( FactoryGirl.build(:user_payment_account) ).to be_valid
  end

  it 'should not accept a bank account number with an invalid account number' do
    expect( FactoryGirl.build(:user_payment_account, bank_account_number: '15032080118') ).not_to be_valid
  end

  it 'should accept a norwegian bank account number with numbers and/or periods in it' do
    expect( FactoryGirl.build(:user_payment_account, bank_account_number: '1503 20..80119') ).to be_valid
  end

  it 'should not accept a bank account number with the wrong number of digits' do
    expect( FactoryGirl.build(:user_payment_account, bank_account_number: '150320801199999') ).not_to be_valid
  end

  it 'should not accept a bank account number with letters in it' do
    expect( FactoryGirl.build(:user_payment_account, bank_account_number: '15032080foo') ).not_to be_valid
  end

  it 'should automatically generate an iban number from a bank account number' do
    expect( FactoryGirl.create(:user_payment_account, bank_account_number: '15032080119').bank_account_iban ).to be == "NO5015032080119"
  end

  it 'should not accept a bank account number without a user connected to it' do
    expect( FactoryGirl.build(:user_payment_account, user_id: nil) ).not_to be_valid
  end
end
