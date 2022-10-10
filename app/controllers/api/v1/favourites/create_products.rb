# frozen_string_literal: true

module API
  module V1
    module Favourites
      class CreateProducts < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "Allows creation of a favourite product entry. Requires authentication.", entity: API::V1::Products::Entities::ShowProductForShopper
          params do
            requires :product_id, type: Integer, desc: 'Id of a product', documentation: { example: 2 }
          end
          post '/products' do
      
            result = ::Favourites::CreateProduct.run(params.merge({shopper_id: current_shopper.id}))
            if result.valid?
              present result.result, with: API::V1::Products::Entities::ShowProductForShopper
            else
              error!(result.errors, 422)
            end
          end
        end
      end
    end
  end
end