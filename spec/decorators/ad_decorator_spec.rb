require 'spec_helper'
require 'rails_helper'

describe AdDecorator do

  let(:ad) { FactoryGirl.build_stubbed(:ad, price: 25012 ) }

  it 'should correctly convert price from ints to numeric' do
    expect( ad.decorate.price ).to eq 250.12
  end
end
