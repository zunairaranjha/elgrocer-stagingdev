FactoryBot.define do
  factory :retailer_has_service do
    min_basket_value { 0 }
    delivery_slot_skip_time { 3600 }
    retailer_service
  end
end
