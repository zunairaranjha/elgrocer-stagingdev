module API
  module V1
    module Favourites
      module Entities
        class IndexProductsEntity < API::BaseEntity
          expose :products, using: API::V1::Products::Entities::ShowProductForShopper, documentation: {type: 'show_product_shopper', is_array: true }
        end                
      end
    end
  end
end