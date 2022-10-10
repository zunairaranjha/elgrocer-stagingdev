FactoryBot.define do
  factory :retailer_opening_hour do
    retailer
    open { (Time.now - 1.hour).seconds_since_midnight }
    close { (Time.now + 1.hour).seconds_since_midnight }
    day { Time.now.wday + 1 }
  end
end
