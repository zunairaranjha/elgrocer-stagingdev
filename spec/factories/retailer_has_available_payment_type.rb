FactoryBot.define do

  factory :retailer_has_available_payment_type do
    retailer_service_id { 1 }
    accept_promocode { true }
  end
end
