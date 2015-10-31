FactoryGirl.define do
  factory :booking_calculator do
    #ad FactoryGirl.build(:ad)

    trait :time_interval_1h do
      starts_at DateTime.now
      ends_at   1.hour.from_now
    end

    trait :time_interval_1day do
      starts_at DateTime.now
      ends_at   1.day.from_now
    end

    trait :time_interval_2days do
      starts_at DateTime.now
      ends_at   2.day.from_now
    end

    trait :time_interval_2day_12h do
      starts_at DateTime.now
      ends_at   2.day.from_now + 12.hours
    end
  end

end
