# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class OpenOrderDetailEntity < API::V1::Orders::Entities::OpenOrderDetailEntity
          expose :estimated_delivery_at, override: true, documentation: { type: 'DateTime', desc: 'Estimated Delivery At' }, format_with: :dateTime
          expose :delivery_slot, merge: true, override: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result,options|
            API::V2::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
        end
      end
    end
  end
end
