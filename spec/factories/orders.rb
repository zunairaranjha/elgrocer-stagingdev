FactoryBot.define do
  factory :order do
    payment_type_id { 1 }
    estimated_delivery_at { Time.now + 1.hours }
    retailer
    shopper
  end
end
