FactoryBot.define do
  factory :shopper_address do
    address_name { 'My place' }
    area { 'MyArea' }
    street { 'Street 9' }
    building_name { 'Bobtower' }
    apartment_number { 1 }
    lonlat { 'POINT (55 25)' }
  end

  trait :with_point do
    lonlat { 'POINT (55.2842 25.2386)' }
  end
end
