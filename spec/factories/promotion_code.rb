FactoryBot.define do
  factory :promotion_code do
    value_cents { 10 }
    value_currency { 'AED' }
    code { 'secret_code' }
    allowed_realizations { 99 }
    start_date { Time.now - 1.day }
    end_date { Time.now + 1.day }
    realizations_per_shopper { 1 }
    realizations_per_retailer { 1 }
    order_limit { '0-1000' }
    data { { title_en: 'test_code', name_en: 'Promotion Code', name_ar: 'Promotion Code' } }
    association :retailers
    association :brands
  end
end
