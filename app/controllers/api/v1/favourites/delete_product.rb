# frozen_string_literal: true

module API
  module V1
    module Favourites
      class DeleteProduct < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "Allows deletion of a favourite product entry. Requires authentication"
          params do
            requires :product_id, type: Integer, desc: 'Id of a product', documentation: { example: 2 }
          end
          delete '/products' do
      
            result = ::Favourites::DeleteProduct.run(params.merge({shopper_id: current_shopper.id}))
            if result.valid?
              result.result
            else
              error!(result.errors, 422)
            end
          end
        end
      end      
    end
  end
end