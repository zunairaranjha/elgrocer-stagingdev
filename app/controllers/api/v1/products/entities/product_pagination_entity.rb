# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ProductPaginationEntity < API::BaseEntity
          expose :next, documentation: { type: 'Bool', desc: "Is something else in list of products?" }, format_with: :bool
          expose :products, using: API::V1::Products::Entities::ShowTopSellingEntity, documentation: {type: 'show_product', is_array: true }
        end                
      end
    end
  end
end