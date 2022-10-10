# frozen_string_literal: true

module API
  module V3
    module Retailers
      class IsCovered < Grape::API
        version 'v3', using: :path
        format :json
      
        resource :retailers do
          desc "Checks if location contains opened shops."
      
          params do
            requires :longitude, type: Float, desc: 'Shopper longitude'
            requires :latitude, type: Float, desc: 'Shopper latitude'
            optional :name, type: String, desc: 'Location name'
            optional :shopper_id, type: Integer, desc: 'Shopper id, is existing shopper', documentation: { example: 20 }
          end
      
          get '/is_covered' do
            is_covered = Rails.cache.fetch([params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).except(:shopper_id),__method__], expires_in: 15.minutes) do
              DeliveryZone::ScheduleShopperService.new(params[:longitude], params[:latitude]).is_covered_and_active?
            end
            if is_covered.blank?
              location_without_shop = ALocationWithoutShop.new(name: params[:name], longitude: params[:longitude], latitude: params[:latitude])
              location_without_shop.shopper_id = params[:shopper_id] unless params[:shopper_id].blank?
              location_without_shop.save
            end
      
            a_location_without_shop_id = location_without_shop.try(:id)
            result = {is_covered: is_covered, location_without_shop_id: a_location_without_shop_id}
            # present params
            # present params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).except(:ip_address)
          end
        end
      end      
    end
  end
end