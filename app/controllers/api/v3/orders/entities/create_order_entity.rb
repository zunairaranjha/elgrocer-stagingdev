# frozen_string_literal: true

module API
  module V3
    module Orders
      module Entities
        class CreateOrderEntity < API::V2::Orders::Entities::CreateOrderEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Date of ordering' }, format_with: :dateTime
          expose :estimated_delivery_at, documentation: { type: 'DateTime', desc: 'Estimated delivery time in case of schedule order' }, format_with: :dateTime
          expose :delivery_slot, override: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result,options|
            API::V2::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
        end
      end
    end
  end
end
