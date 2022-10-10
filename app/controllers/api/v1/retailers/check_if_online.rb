# frozen_string_literal: true

module API
  module V1
    module Retailers
      class CheckIfOnline < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc "Checks if location contains opened shops."
      
          params do
            requires :longitude, type: Float, desc: 'Shopper longitude'
            requires :latitude, type: Float, desc: 'Shopper latitude'
          end
      
          get '/are_online' do
            DeliveryZone::ShopperService.new(params[:longitude], params[:latitude]).retailers_on_line?
          end
        end
      end      
    end
  end
end