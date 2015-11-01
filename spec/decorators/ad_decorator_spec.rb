require 'spec_helper'
require 'rails_helper'



describe AdDecorator do

  let(:ad) { FactoryGirl.create(:ad,
    user: FactoryGirl.build( :user ),
    payin_rules: [ FactoryGirl.create( :payin_rule, unit: 'day', effective_from: 1, payin_amount: 250_73 ) ]
    ).decorate
  }

  it { expect(ad).to be_decorated_with AdDecorator }

  it 'should correctly convert price from ints to numeric' do
    expect( ad.price ).to eq 250.73
  end
end
