# frozen_string_literal: true

module Concerns
  module OrderParamHelper
    extend Grape::API::Helpers

    params :create_order_param do
      requires :retailer_service_id, type: Integer, desc: 'Delivery Method of order', documentation: { example: 3 }
      requires :retailer_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
      requires :payment_type_id, type: Integer, desc: 'ID of the payment type', documentation: { example: 2 }
      requires :vat, type: Integer, desc: 'Value Added TAX %'
      requires :products, type: Array do
        requires :amount, type: Integer, desc: 'Desired amount of product', documentation: { example: 5 }
        requires :product_id, type: Integer, desc: 'Desired amount of product', documentation: { example: 5 }
      end
      optional :shopper_address_id, type: Integer, desc: "ID of the shopper's address", documentation: { example: 16 }
      optional :usid, type: Integer, desc: 'Delivery Slot ID', documentation: { example: 16 }
      optional :promotion_code_realization_id, type: Integer, desc: 'ID of the promotion code realization'
      optional :shopper_note, type: String, desc: 'Shopper note for retailer'
      optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS, 2 - Web)"
      optional :collector_detail_id, type: Integer, desc: 'Collector Detail Id', documentation: { example: 3 }
      optional :vehicle_detail_id, type: Integer, desc: 'Vehicle Detail Id', documentation: { example: 3 }
      optional :pickup_location_id, type: Integer, desc: 'pickup location Id', documentation: { example: 3 }
      optional :substitution_preference_key, type: Integer, desc: 'substitution preference key', documentation: { example: 3 }
    end
  end
end
