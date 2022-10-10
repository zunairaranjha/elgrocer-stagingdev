# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class CncAvailabilityEntity < API::V1::Retailers::Entities::ClickAndCollectAvailabilityEntity
          expose :delivery_slots, using: API::V2::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', is_array: true }

          def delivery_slots
            if retailer_delivery_type_id == 1
              object.next_slot_cc
            else
              []
            end
          end
        end
      end
    end
  end
end
