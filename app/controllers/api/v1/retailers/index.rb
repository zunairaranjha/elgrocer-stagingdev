# frozen_string_literal: true

module API
  module V1
    module Retailers
      class Index < Grape::API
        version 'v1', using: :path
        format :json

        resource :retailers do
          desc 'lists all retailers', entity: API::V1::Retailers::Entities::ListEntity
          params do
            optional :search, type: String, desc: 'Search Company name'
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
          end
          get '/list' do
            retailers = Retailer.where("company_name ILIKE '%#{params[:search]}%'").where(is_active: true)
                                .select(:id, :company_name, :slug, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :updated_at)
                                .order(:company_name).limit(params[:limit]).offset(params[:offset])
            present retailers, with: API::V1::Retailers::Entities::ListEntity
          end

          desc 'List of all retailers. Requires authentication.', entity: API::V1::Retailers::Entities::IndexEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
          end
          get '/all' do
            shopper_service = DeliveryZone::ShopperService.new(params[:longitude], params[:latitude])
            if shopper_service.retailers_on_line?
              retailers = shopper_service.retailers_active_all
              @is_next = retailers.size > params[:limit] + params[:offset]
              retailers = retailers
                            .select('retailers.*, max(retailer_delivery_zones.min_basket_value) min_basket_value')
                            .order(:created_at)
                            .limit(params[:limit])
                            .offset(params[:offset])
                            .group('retailers.id')
            else
              retailers = Retailer.without_delivery_zone
            end

            result = { is_next: @is_next, retailers: retailers }
            present result, with: API::V1::Retailers::Entities::IndexEntity, params: params
          end
        end
      end
    end
  end
end
