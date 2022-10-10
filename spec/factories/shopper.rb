FactoryBot.define do
  factory :shopper do
    sequence(:email) { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:phone_number) { Faker::PhoneNumber.cell_phone_in_e164.first(13).ljust(13, '0') }
    name { Faker::Name.name }
  end
end
