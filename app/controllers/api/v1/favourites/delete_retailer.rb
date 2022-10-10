# frozen_string_literal: true

module API
  module V1
    module Favourites
      class DeleteRetailer < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "Allows deletion of a favourite retailer entry. Requires authentication"
          params do
            requires :retailer_id, type: Integer, desc: 'Id of a retailer', documentation: { example: 2 }
          end
          delete '/retailers' do
      
            result = ::Favourites::DeleteRetailer.run(params.merge({shopper_id: current_shopper.id}))
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