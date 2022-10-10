# frozen_string_literal: true

module API
  module V1
    module PickupLocations
      class Index < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :pickup_locations do
          desc "List of all pickup locations according to retailer"
      
          params do
            requires :retailer_id, type: Integer, desc: "Retailer id of collector"
          end
      
          get '/all' do
            result = PickupLoc.where(retailer_id: params[:retailer_id], is_active: true)
            present result, with: API::V1::PickupLocations::Entities::IndexEntity
          end
        end
      end
    end
  end
end