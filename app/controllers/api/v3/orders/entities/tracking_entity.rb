# frozen_string_literal: true

module API
  module V3
    module Orders
      module Entities
        class TrackingEntity < API::BaseEntity
          root 'trackings', 'tracking'

          def self.entity_name
            'order_tracking'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :status_id, documentation: { type: 'Integer', desc: 'ID of the status' }, format_with: :integer
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :delivery_slot, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" }

        end
      end
    end
  end
end
