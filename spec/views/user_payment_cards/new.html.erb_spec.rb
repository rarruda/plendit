require 'rails_helper'

RSpec.describe "user_payment_cards/new", type: :view do
  before(:each) do
    assign(:user_payment_card, UserPaymentCard.new(
      :guid => "MyString",
      :user => nil,
      :card_vid => "MyString",
      :currency => "MyString",
      :card_type => "MyString",
      :access_key => "MyString",
      :preregistration_data => "MyText",
      :registration_data => "MyString",
      :card_registration_url => "MyString",
      :number_alias => "MyString",
      :expiration_date => "MyString",
      :last_known_status_mp => "MyString",
      :validity_mp => "MyString",
      :active_mp => ""
    ))
  end

  xit "renders new user_payment_card form" do
    render

    assert_select "form[action=?][method=?]", user_payment_cards_path, "post" do

      assert_select "input#user_payment_card_guid[name=?]", "user_payment_card[guid]"

      assert_select "input#user_payment_card_user_id[name=?]", "user_payment_card[user_id]"

      assert_select "input#user_payment_card_card_vid[name=?]", "user_payment_card[card_vid]"

      assert_select "input#user_payment_card_currency[name=?]", "user_payment_card[currency]"

      assert_select "input#user_payment_card_card_type[name=?]", "user_payment_card[card_type]"

      assert_select "input#user_payment_card_access_key[name=?]", "user_payment_card[access_key]"

      assert_select "textarea#user_payment_card_preregistration_data[name=?]", "user_payment_card[preregistration_data]"

      assert_select "input#user_payment_card_registration_data[name=?]", "user_payment_card[registration_data]"

      assert_select "input#user_payment_card_card_registration_url[name=?]", "user_payment_card[card_registration_url]"

      assert_select "input#user_payment_card_number_alias[name=?]", "user_payment_card[number_alias]"

      assert_select "input#user_payment_card_expiration_date[name=?]", "user_payment_card[expiration_date]"

      assert_select "input#user_payment_card_last_known_status_mp[name=?]", "user_payment_card[last_known_status_mp]"

      assert_select "input#user_payment_card_validity_mp[name=?]", "user_payment_card[validity_mp]"

      assert_select "input#user_payment_card_active_mp[name=?]", "user_payment_card[active_mp]"
    end
  end
end
