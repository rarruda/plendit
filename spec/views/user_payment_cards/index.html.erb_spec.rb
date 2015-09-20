require 'rails_helper'

RSpec.describe "user_payment_cards/index", type: :view do
  before(:each) do
    assign(:user_payment_cards, [
      UserPaymentCard.create!(
        :guid => "Guid",
        :user => nil,
        :card_vid => "Card Vid",
        :currency => "Currency",
        :card_type => "Card Type",
        :access_key => "Access Key",
        :preregistration_data => "MyText",
        :registration_data => "Registration Data",
        :card_registration_url => "Card Registration Url",
        :number_alias => "Number Alias",
        :expiration_date => "Expiration Date",
        :last_known_status_mp => "Last Known Status Mp",
        :validity_mp => "Validity Mp",
        :active_mp => ""
      ),
      UserPaymentCard.create!(
        :guid => "Guid",
        :user => nil,
        :card_vid => "Card Vid",
        :currency => "Currency",
        :card_type => "Card Type",
        :access_key => "Access Key",
        :preregistration_data => "MyText",
        :registration_data => "Registration Data",
        :card_registration_url => "Card Registration Url",
        :number_alias => "Number Alias",
        :expiration_date => "Expiration Date",
        :last_known_status_mp => "Last Known Status Mp",
        :validity_mp => "Validity Mp",
        :active_mp => ""
      )
    ])
  end

  xit "renders a list of user_payment_cards" do
    render
    assert_select "tr>td", :text => "Guid".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Card Vid".to_s, :count => 2
    assert_select "tr>td", :text => "Currency".to_s, :count => 2
    assert_select "tr>td", :text => "Card Type".to_s, :count => 2
    assert_select "tr>td", :text => "Access Key".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Registration Data".to_s, :count => 2
    assert_select "tr>td", :text => "Card Registration Url".to_s, :count => 2
    assert_select "tr>td", :text => "Number Alias".to_s, :count => 2
    assert_select "tr>td", :text => "Expiration Date".to_s, :count => 2
    assert_select "tr>td", :text => "Last Known Status Mp".to_s, :count => 2
    assert_select "tr>td", :text => "Validity Mp".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
