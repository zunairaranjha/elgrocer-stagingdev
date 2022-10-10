module API
  module V1
    module VehicleDetails
      module Entities
        class ShowColorEntity < API::BaseEntity
          root 'vehicle_colors', 'vehicle_color'

          def self.entity_name
            'show_color_entity'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Color id' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name Of color' }, format_with: :string
          expose :color_code, documentation: { type: 'String', desc: 'Color Code' }, format_with: :string
        end
      end
    end
  end
end