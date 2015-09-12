require 'faker'

FactoryGirl.define do
  factory :user_bank_account do |f|
    # from http://www.iban-bic.com/sample_accounts.html
    f.user_id { "1" }
    f.bank_account_number { "15032080119" }
  end
end
