module API
  module V1
    module Retailers
      module Entities
        class IndexEntity < API::BaseEntity
          expose :retailers, using: API::V1::Retailers::Entities::ShowRetailer, documentation: {type: 'show_retailer', is_array: true }
          expose :is_next, documentation: {type: "Boolean", desc: "Determines if therea are more records in the database"}, format_with: :bool
        end                
      end
    end
  end
end