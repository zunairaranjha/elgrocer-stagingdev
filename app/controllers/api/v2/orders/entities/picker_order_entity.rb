# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class PickerOrderEntity < API::V1::Orders::Entities::ListEntity
          unexpose :retailer_id
          unexpose :retailer_phone_number
          unexpose :retailer_company_name
          unexpose :retailer_opening_time
          unexpose :retailer_company_address
          unexpose :retailer_contact_email
          unexpose :retailer_delivery_range
          unexpose :is_approved
          expose :retailer_service_id, documentation: { type: 'Integer', desc: 'Retailer Service Id' }, format_with: :integer
          expose :collector_detail, using: API::V1::CollectorDetails::Entities::IndexEntity, documentation: { type: 'show_collector_detail', is_array: true }
          expose :vehicle_detail, using: API::V1::VehicleDetails::Entities::ShowEntity, documentation: { type: 'show_vehicle_detail', is_array: true }
          expose :pickup_location, using: API::V1::PickupLocations::Entities::IndexEntity, documentation: { type: 'show_pickup_Location', is_array: true }
          expose :adyen, documentation: { type: 'Boolean', desc: 'Adyen Order or Not' }, format_with: :bool

          def collector_detail
            object.collector_detail
          end

          def vehicle_detail
            object.vehicle_detail
          end

          def pickup_location
            object.pickup_loc
          end

          def adyen
            object.payment_type_id == 3 && object.card_detail.present? && object.card_detail['ps'].to_s.eql?('adyen')
          end
        end
      end
    end
  end
end