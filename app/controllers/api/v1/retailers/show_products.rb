# frozen_string_literal: true

module API
  module V1
    module Retailers
      class ShowProducts < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc "Returns products of a retailer.", entity: API::V1::Retailers::Entities::ShowProductEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID'
            optional :brand_id, type: Integer, desc: 'Brand ID'
            optional :category_id, type: Integer, desc: 'Category ID'
          end
      
          get '/products' do
            result = ::Retailers::ShowProducts.run(params)
            if result.valid?
              present result.result.second, with: API::V1::Retailers::Entities::ShowProductEntity, retailer_id: params[:retailer_id]
            else
              error!({error_code: 403, error_message: "Retailer does not exist"},403)
            end
            # result.result
          end
      
        end
      end      
    end
  end
end