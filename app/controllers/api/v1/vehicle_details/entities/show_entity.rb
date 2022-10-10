module API
  module V1
    module VehicleDetails
      module Entities
        class ShowEntity < API::BaseEntity
          expose :id, documentation: { type: 'Integer', desc: 'id of Vehicle' }, format_with: :integer
          expose :plate_number, documentation: { type: 'String', desc: 'Number of Vehicle' }, format_with: :string
          expose :vehicle_model, using: API::V1::VehicleDetails::Entities::ShowVehicleModelEntity, documentation: { type: 'vehicle_model', is_array: true }
          expose :color, as: :vehicle_color, using: API::V1::VehicleDetails::Entities::ShowColorEntity, documentation: { type: 'vehicle_color', is_array: true }
          expose :company, documentation: { type: 'String', desc: 'Company of Vehicle' }, format_with: :string
          # expose :collector_id, documentation: { type: 'Integer', desc: 'Collector id of Vehicle' }, format_with: :integer        
        end
      end
    end
  end
end