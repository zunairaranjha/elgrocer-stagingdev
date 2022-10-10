module API
  module V1
    module Retailers
      class IsCoveredForRetailer < Grape::API
        version 'v1', using: :path
        format :json

        resource :retailers do
          desc "Checks if location contains opened shops."

          params do
            requires :longitude, type: Float, desc: 'Shopper longitude'
            requires :latitude, type: Float, desc: 'Shopper latitude'
            requires :retailer_id, desc: 'Retailer id'
          end

          get '/is_covered_for_retailer' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            if retailer
              DeliveryZone::ShopperService.new(params[:longitude], params[:latitude]).is_covered_for_retailer?(retailer.id)
            else
              error!({ error_code: 403, error_message: "Retailer does not exist" }, 403)
            end
          end
        end
      end
    end
  end
end