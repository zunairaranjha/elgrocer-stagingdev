module API
  module V1
    module Cities
      module Entities
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_city'
          end
          expose :id, documentation: { type: 'Integer', desc: "Location id" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Location name" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
        end
                
      end
    end
  end
end