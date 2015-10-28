FactoryGirl.define do
  factory :price do

    # https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#building-or-creating-multiple-records
    #after(:create) do |p|
    #  FactoryGirl.create_pair(:price_item, price: p )
    #end
    after(:create) do |p|
      FactoryGirl.create(:price_item, price: p, unit: 'day',  amount: 200_00 )
    end

    factory :price_week do
      after(:create) do |p|
        FactoryGirl.create(:price_item, price: p, unit: 'day', amount: 100_00, effective_from_unit: 3 )
        FactoryGirl.create(:price_item, price: p, unit: 'day', amount: 90_00, effective_from_unit: 7 )
      end
    end

    factory :price_hour do
      after(:create) do |p|
        FactoryGirl.create(:price_item, price: p, unit: 'hour', amount: 25_00 )
      end
    end
  end

end
