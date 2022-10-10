class RetailerHasAvailablePaymentType < ActiveRecord::Base
    belongs_to :retailer, optional: true, touch: true
    belongs_to :available_payment_type, optional: true

    scope :delivery, -> { where(retailer_service_id: 1) }
    scope :click_and_collect, -> { where(retailer_service_id: 2) }
end