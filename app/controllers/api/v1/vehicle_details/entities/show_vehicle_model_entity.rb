module API
  module V1
    module VehicleDetails
      module Entities
        class ShowVehicleModelEntity < API::BaseEntity
          root 'vehicle_models', 'vehicle_model'

          def self.entity_name
            'show_vehicle_model_entity'
          end
          expose :id, documentation: { type: 'Integer', desc: 'Color id' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name Of Model' }, format_with: :string
        end
      end
    end
  end
end