# frozen_string_literal: true

module API
  module V1
    module Locations
      class Index < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :locations do
          desc "List of all locations.", entity: API::V1::Locations::Entities::ShowEntity
          params do
            optional :limit, type: Integer, desc: 'Limit', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset', documentation: { example: 10 }
            optional :city_id, desc: 'City ID or Slug', documentation: { example: "10 or dubai" }
            optional :primary_location_id, desc: 'Location ID or Slug', documentation: { example: "10 or al-barsh" }
            optional :retailer_id, desc: 'retailer_id', documentation: { example: "10 or ryan-market" }
          end
          get do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.find_by(slug: params[:retailer_id]) : Retailer.find_by(id: params[:retailer_id]) if params['retailer_id'].present?
      
            result = Location.joins(:retailers).where(retailers: { is_active: true }).order(:name).limit(params['limit']).offset(params['offset']).distinct
            result = result.includes(:city)
            result = result.where(city_id: City.find(params['city_id'])) if params['city_id'].present?
            result = result.where(primary_location_id: Location.find(params['primary_location_id'])) if params['primary_location_id'].present?
            result = result.where('retailer_id = ?', retailer.id) if params['retailer_id'].present?
            result = result.select("locations.*, retailer_has_locations.id > 0 covered")
            present result, with: API::V1::Locations::Entities::ShowEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end