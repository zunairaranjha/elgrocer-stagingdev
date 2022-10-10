# frozen_string_literal: true

module API
  module V1
    module Favourites
      class IndexRetailers < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :favourites do
          desc "List of all favourite retailers of a user.", entity: API::V1::Favourites::Entities::IndexRetailersEntity
          params do
            optional :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            optional :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
          end
          get '/retailers' do
            retailers = current_shopper.favourite_retailers.where('delivery_type_id != 1')
            
            if params[:longitude] && params[:latitude]
              retailers = retailers.joins("LEFT JOIN retailer_delivery_zones INNER JOIN delivery_zones on delivery_zones.id = retailer_delivery_zones.delivery_zone_id and ST_Contains(delivery_zones.coordinates, ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) = 't' on retailers.id = retailer_delivery_zones.retailer_id")
              .joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
              .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
              .select('retailers.*, max(retailer_delivery_zones.min_basket_value) min_basket_value, max(retailer_delivery_zones.id) retailer_delivery_zones_id, max(delivery_zones.id) delivery_zones_id,(is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen')
              .group('retailers.id')
            end
      
            result = {retailers: retailers}
            present result, with: API::V1::Favourites::Entities::IndexRetailersEntity, shopper_id: current_shopper.id
          end
        end
      end
    end
  end
end