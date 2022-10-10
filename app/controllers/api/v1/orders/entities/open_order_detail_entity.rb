module API
  module V1
    module Orders
      module Entities
        class OpenOrderDetailEntity < API::V1::Orders::Entities::OpenOrderListEntity

          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :shopper_name, documentation: { type: 'String', desc: 'Name of the shopper' }, format_with: :string
          expose :shopper_phone_number, documentation: { type: 'String', desc: 'phone no of the shopper' }, format_with: :string
          expose :shopper_address_name, documentation: { type: 'String', desc: "Shopper's address name" }, format_with: :string
          expose :shopper_address_area, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_street, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_building_name, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_apartment_number, documentation: { type: 'String', desc: "Shopper's apartment number" }, format_with: :string
          expose :shopper_address_longitude, documentation: { type: 'Float', desc: "Shopper's longitude" }, format_with: :float
          expose :shopper_address_latitude, documentation: { type: 'Float', desc: "Shopper's latitude" }, format_with: :float
          expose :shopper_address_location_name, documentation: { type: 'String', desc: "Shopper's location_name" }, format_with: :string
          expose :shopper_address_location_address, documentation: { type: 'String', desc: "Shopper's location_address" }, format_with: :string
          expose :shopper_address_floor, documentation: { type: 'String', desc: "Shopper's address floor" }, format_with: :string
          expose :shopper_address_additional_direction, documentation: { type: 'String', desc: "Shopper's additional direction" }, format_with: :string
          expose :shopper_address_house_number, documentation: { type: 'String', desc: "Shopper's address house number" }, format_with: :string
          expose :shopper_address_type_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer
          expose :shopper_address_type, documentation: { type: 'String', desc: "Shopper's address name" }, format_with: :string
          expose :collector_detail, using: API::V1::CollectorDetails::Entities::IndexEntity, documentation: { type: 'show_collector_detail', is_array: true }
          expose :vehicle_detail, using: API::V1::VehicleDetails::Entities::ShowEntity, documentation: { type: 'show_vehicle_detail', is_array: true }
          expose :pickup_location, using: API::V1::PickupLocations::Entities::IndexEntity, documentation: { type: 'show_pickup_Location', is_array: true }
          expose :picker, using: API::V1::Employees::Entities::EmployeeInOrderEntity, documentation: { type: 'picker_detail', is_array: true }

          def collector_detail
            object.collector_detail
          end

          def vehicle_detail
            object.vehicle_detail
          end

          def pickup_location
            object.pickup_loc
          end

          def picker
            object.active_employee
          end

        end
      end
    end
  end
end
