# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class DeliveryRetailerEntity < API::V2::Retailers::Entities::ShowRetailer
          # unexpose :opening_time
          expose :delivery_slots, using: API::V2::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', is_array: true }
          expose :date_time_offset, documentation: { type: 'String', desc: 'Date Time Offset' }, format_with: :string

          def delivery_slots
            rdzid = object.try('retailer_delivery_zones_id')
            object.next_slot_delivery.select { |avs| avs.retailer_delivery_zone_id == rdzid }
          end
        end
      end
    end
  end
end
