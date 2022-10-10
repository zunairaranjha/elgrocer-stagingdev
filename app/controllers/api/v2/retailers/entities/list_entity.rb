# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class ListEntity < API::BaseEntity
          expose :store_types, using: API::V2::Retailers::Entities::StoreTypeEntity, documentation: { type: 'show_store_type', is_array: true }
          expose :retailers, using: API::V2::Retailers::Entities::ShowRetailer, documentation: { type: 'show_retailer', is_array: true }
          expose :is_next, documentation: { type: "Boolean", desc: "Determines if therea are more records in the database" }, format_with: :bool
        end
      end
    end
  end
end
