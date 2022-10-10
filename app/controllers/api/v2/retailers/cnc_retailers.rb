# frozen_string_literal: true

module API
  module V2
    module Retailers
      class CncRetailers < Grape::API
        version 'v2', using: :path
        format :json

        resource :retailers do
          desc 'List of retailers according to shopper location!'
          params do
            optional :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
          end

          get '/cc_availability' do
            radius = RetailerService.find_by(id: 2)&.availability_radius
            retailers = Retailer.includes(:next_slot_cc).where("retailers.is_active IS TRUE AND opening_time<>''")
                                .joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                .where("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) <= #{radius}")
                                .select("retailers.id, retailers.company_name, retailers.company_name_ar, retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.retailer_group_id, retailers.report_parent_id,
                                         retailer_has_services.delivery_type AS retailer_delivery_type, retailer_has_services.min_basket_value, retailers.is_opened")
                                .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.delivery_type')
            retailers = retailers.joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
            retailers = retailers.select('ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids')
            present message: retailers.length.positive?
            present retailers, with: API::V2::Retailers::Entities::CncAvailabilityEntity
          end
        end
      end
    end
  end
end
