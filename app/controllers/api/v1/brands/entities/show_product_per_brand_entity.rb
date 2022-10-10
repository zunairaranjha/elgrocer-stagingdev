
module API
  module V1
    module Brands
      module Entities
        class ShowProductPerBrandEntity < API::BaseEntity
          expose :products, using: API::V1::Products::Entities::ShowEntity, documentation: {type: 'show_product', is_array: true }
        end                
      end
    end
  end
end