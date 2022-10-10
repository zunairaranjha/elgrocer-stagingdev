# frozen_string_literal: true

module API
  module V1
    module Favourites
      class CreateRetailers < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "Allows creation of a favourite retailer entry. Requires authentication", entity: API::V1::Retailers::Entities::ShowRetailer
          params do
            requires :retailer_id, type: Integer, desc: 'Id of a product', documentation: { example: 2 }
          end
          post '/retailers' do
      
            result = ::Favourites::CreateRetailer.run(params.merge({shopper_id: current_shopper.id}))
            if result.valid?
              present result.result, with: API::V1::Retailers::Entities::ShowRetailer, shopper_id: current_shopper.id
            else
              error!(result.errors, 422)
            end
          end
        end
      end      
    end
  end
end