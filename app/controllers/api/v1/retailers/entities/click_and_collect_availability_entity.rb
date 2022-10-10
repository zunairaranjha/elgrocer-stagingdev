module API
  module V1
    module Retailers
      module Entities
        class ClickAndCollectAvailabilityEntity < API::V1::Retailers::Entities::ClickAndCollect
          unexpose :slug
          unexpose :photo1_url
          #  unexpose :min_basket_value
          unexpose :is_opened
          unexpose :is_show_recipe
          unexpose :available_payment_types
          unexpose :delivery_type_id
          unexpose :delivery_type
          unexpose :service_fee
          unexpose :vat
          unexpose :distance
          unexpose :retailer_group_name
          unexpose :latitude
          unexpose :longitude
          unexpose :retailer_type
          # unexpose :store_category_ids
          expose :delivery_slots, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', is_array: true }

          private

          def delivery_slots
            ds = []
            if retailer_delivery_type_id != 1 and object.is_opened
              ds.push(DeliverySlot.new(id: 0, day: Time.now.wday + 1, start: 28800, end: 79200, products_limit: 0))
            end

            if retailer_delivery_type_id == 1
              object.next_available_slots_cc
            else
              ds
            end
          end
        end
      end
    end
  end
end
