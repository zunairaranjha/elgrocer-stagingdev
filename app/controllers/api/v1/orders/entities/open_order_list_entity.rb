# frozen_string_literal: true

module API
  module V1
    module Orders
      module Entities
        class OpenOrderListEntity < API::BaseEntity
          expose :id,  documentation: { type: 'Integer', desc: 'id of Order' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'id of Retailer' }, format_with: :integer
          expose :retailer_company_name, documentation: { type: 'String', desc: 'Name of Retailer' }, format_with: :string
          expose :status_id, documentation: { type: 'Integer', desc: 'Order Status ID' }, format_with: :integer
          expose :delivery_type_id, documentation: { type: 'Integer', desc: 'Order Delivery Type Id' }, format_with: :integer
          expose :retailer_service_id, documentation: { type: 'Integer', desc: 'Retailer Service Id' }, format_with: :integer
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'Estimated Delivery At' }, format_with: :string
          expose :delivery_slot, merge: true, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" } do |result,options|
            API::V1::DeliverySlots::Entities::ListEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
          expose :tracking_url, documentation: { type: 'String', desc: 'Delivery Tracking Url' }, format_with: :string

          private

          def tracking_url
            object.card_detail.to_h['tracking_url'].to_s if object.status_id == 2 && object.retailer_service_id == 1
          end
        end
      end
    end
  end
end
