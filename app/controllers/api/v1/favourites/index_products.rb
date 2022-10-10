# frozen_string_literal: true

module API
  module V1
    module Favourites
      class IndexProducts < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "List of all favourite products for a user.", entity: API::V1::Favourites::Entities::IndexProductsEntity
          get '/products' do
            products = current_shopper.favourite_products
            result = {products: products}
            present result, with: API::V1::Favourites::Entities::IndexProductsEntity
          end
        end
      end      
    end
  end
end