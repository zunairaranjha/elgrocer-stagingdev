module API
  module V1
    module AddressTags
      module Entities
        class IndexEntity < API::BaseEntity
          root 'address_tags', 'address_tag'
        
          def self.entity_name
            'index_address_tag'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'Id of the address tag' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of the address tag' }, format_with: :string
        
        end
        
      end
    end
  end
end