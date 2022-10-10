module API
  module V1
    module Webhooks
      module Entities
        class StoreTypeEntity < API::BaseEntity

          def self.entity_name
            'show_store_type'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of Store Type' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Name of Store Type." }, format_with: :string

        end
      end
    end
  end
end
