FactoryBot.define do
  sequence(:email) { Faker::Internet.email }
  sequence(:contact_email) { Faker::Internet.safe_email }
  factory :retailer do
    # sequence(:authentication_token) { |n| "abc#{n}"}
    email
    contact_email
    password { 'awesomepassword' }
    password_confirmation { 'awesomepassword' }
    company_name { 'Test name' }
    company_address { 'Test address' }
    phone_number { '777666555' }
    opening_time { '9:00 - 18:00' }
    delivery_range { 20 }
    latitude { -45.756688 }
    longitude { 120.5777777 }
    commission_value { 10 }
    show_pending_order_hours { 2 }
    date_time_offset { 'Asia/Dubai' }
    location
  end

  trait :with_delivery_zone do
    is_active { true }
    is_opened { true }
    delivery_zones { [FactoryBot.create(:delivery_zone)] }
  end

  trait :with_operator_google do
    retailer_operators { [build(:retailer_operator)]}
  end

  trait :with_retailer_service do
    retailer_services { [FactoryBot.create(:retailer_has_service)]}
  end
end
