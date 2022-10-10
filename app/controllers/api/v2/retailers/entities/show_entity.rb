# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class ShowEntity < API::V3::Retailers::Entities::ShowRetailer
          unexpose :opening_time, :top_searches, :add_day
          expose :delivery_slots, using: API::V2::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', is_array: true }

          def delivery_slots
            rdzid = object.try('retailer_delivery_zones_id')
            object.next_slot_delivery.select { |avs| avs.retailer_delivery_zone_id == rdzid }
          end
        end
      end
    end
  end
end
