class PromotionCodeAvailablePaymentType < ActiveRecord::Base
  belongs_to :promotion_code, optional: true
  belongs_to :available_payment_type, optional: true
end
