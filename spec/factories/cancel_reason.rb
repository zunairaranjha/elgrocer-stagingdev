# frozen_string_literal: true

FactoryBot.define do
  factory :system_configuration do
    key { 'order_cancel' }
    value { { "1": { "en": "Some of the items are not available", "ar": "بعض المنتجات غير متوفرة" }, "2": { "en": "I placed the order by mistake / duplicate order.", "ar": "لقد قدمت الطلب عن طريق الخطأ / طلب مكرر." }, "3": { "en": "I want to use a different payment method", "ar": "أرغب في استخدام طريقة دفع أخرى" }, "4": { "en": "I'm not available to receive the order", "ar": "لست متواجدًا لاستلام الطلب" }, "5": { "en": "I couldn't edit order", "ar": "لم أتمكن من تعديل الطلب" }, "6": { "en": "Other", "ar": "أخرى" } }.to_json }
  end
end
