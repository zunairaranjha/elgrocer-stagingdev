# frozen_string_literal: true

module API
  module V1
    module Retailers
      class ClickAndCollect < Grape::API
        version 'v1', using: :path
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
            retailers = Retailer.includes(:next_available_slots_cc).where("retailers.is_active IS TRUE AND opening_time<>''").joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                .where("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) <= #{radius}")
                                .select("retailers.id, retailers.company_name, retailers.company_name_ar, retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.retailer_group_id, retailers.report_parent_id,
                                         retailer_has_services.delivery_type AS retailer_delivery_type, retailer_has_services.min_basket_value, retailers.is_opened")
                                .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.delivery_type')
            retailers = retailers.joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
            retailers = retailers.select('ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids')
            present message: retailers.length.positive?
            present retailers, with: API::V1::Retailers::Entities::ClickAndCollectAvailabilityEntity
          end

          desc 'List of retailers according to shopper location!'
          params do
            optional :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
          end

          get '/click_and_collect' do
            radius = RetailerService.find_by(id: 2)&.search_radius
            retailers = Retailer.includes(:city, :retailer_group)
                                .where("retailers.is_active IS TRUE AND opening_time<>''")
                                .joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                .distinct
            retailers = retailers.for_cc_api_with_point(params[:longitude], params[:latitude], radius)
            colored_logo = (request.headers['User-Agent'].include?('ElGrocerShopper') && request.headers['App-Version'].to_s > '6.5.20') || request.headers['Version-Code'].to_i > 2384 || (request.headers['Origin'] && request.headers['App-Version'].to_i.positive?)
            store_types = colored_logo ? StoreType.includes(:image) : StoreType
            if retailers.length.positive?
              store_types = store_types.joins('LEFT JOIN retailer_store_types ON retailer_store_types.store_type_id = store_types.id')
                                     .where("retailer_store_types.retailer_id in (#{retailers.map { |ret| ret.id }.join(",")}) or store_types.id = 0").distinct.order(:priority)
            else
              store_types = store_types.joins(:retailer_store_types).where(retailer_store_types: { retailer_id: retailers.map { |ret| ret.id } }).distinct.order(:priority)
            end
            # result = { is_next: false, retailers: retailers, store_types: store_types }
            retailers.cc_ret_preload_payment_types(retailers)
            show_online_payment = true
            config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
              config = Setting.select(:id, :ios_version, :android_version, :web_version).first
            end
            show_online_payment = false if (request.headers['User-Agent'].include?('ElGrocerShopper') and config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
            present is_next: false
            present store_types, with: API::V2::Retailers::Entities::StoreTypeEntity, colored_logo: colored_logo
            present retailers, with: API::V1::Retailers::Entities::ClickAndCollect, show_online_payment: show_online_payment
          end


          desc 'List of retailers with smiles according to shopper location!'
          params do
            optional :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
          end

          get '/click_and_collect_stores' do
            radius = RetailerService.find_by(id: 2)&.search_radius
            retailers = Retailer.includes(:city, :retailer_group)
                                .where("retailers.is_active IS TRUE AND opening_time<>''")
                                .joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                .distinct
            retailers = retailers.for_cc_api_with_point(params[:longitude], params[:latitude], radius)
            colored_logo = (request.headers['User-Agent'].include?('ElGrocerShopper') && request.headers['App-Version'].to_s > '6.5.20') || request.headers['Version-Code'].to_i > 2384 || (request.headers['Origin'] && request.headers['App-Version'].to_i.positive?)
            store_types = colored_logo ? StoreType.includes(:image) : StoreType
            if retailers.length.positive?
              store_types = store_types.joins('LEFT JOIN retailer_store_types ON retailer_store_types.store_type_id = store_types.id')
                                       .where("retailer_store_types.retailer_id in (#{retailers.map { |ret| ret.id }.join(",")}) or store_types.id = 0").distinct.order(:priority)
            else
              store_types = store_types.joins(:retailer_store_types).where(retailer_store_types: { retailer_id: retailers.map { |ret| ret.id } }).distinct.order(:priority)
            end
            # result = { is_next: false, retailers: retailers, store_types: store_types }
            show_online_payment = true
            config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
              config = Setting.select(:id, :ios_version, :android_version, :web_version).first
            end
            show_online_payment = false if (request.headers['User-Agent'].include?('ElGrocerShopper') and config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
            present is_next: false
            present store_types, with: API::V2::Retailers::Entities::StoreTypeEntity, colored_logo: colored_logo
            present retailers, with: API::V1::Retailers::Entities::ClickAndCollect, show_online_payment: show_online_payment, except: %i[available_payment_types]
          end


          desc 'Retailers according to shopper location!'
          params do
            requires :id, desc: 'Retailer ID'
            optional :latitude, type: Float, desc: 'Latitude Of Shopper', documentation: { example: 2.3456789 }
            optional :longitude, type: Float, desc: 'Longitude of Shopper', documentation: { example: 55.86567565 }
            optional :parent_id, type: Integer, desc: 'Parent Id for retailer', documentation: { example: 16 }
          end

          get '/click_and_collect/retailer' do
            retailers = params[:id][/\p{L}/] ? Retailer.where(slug: params[:id]) : Retailer.where("retailers.id = #{params[:id].to_i} or retailers.report_parent_id = #{params[:parent_id].to_i}")
            retailers = retailers.includes(:click_and_collect_payment_types, :city, :retailer_group, :next_available_slots_cc).joins(:click_and_collect_service)
                                 .where(retailer_has_services: { is_active: true })
                                 .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                 .distinct
            if params[:latitude] and params[:longitude]
              radius = RetailerService.find_by(id: 2)&.availability_radius
              retailers = retailers.select("retailers.id, retailers.report_parent_id, retailers.company_name, retailers.company_name_ar, retailers.slug, retailers.is_opened, retailers.is_show_recipe, retailers.retailer_type, retailers.retailer_group_id,
                                  retailers.latitude, retailers.longitude, retailer_has_services.delivery_slot_skip_time AS delivery_slot_skip_hours, retailer_has_services.cutoff_time, retailer_has_services.delivery_type AS retailer_delivery_type,
                                  retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.location_id,
                                  retailers.photo1_file_name, retailers.photo1_content_type, retailers.photo1_file_size, retailers.photo1_updated_at,
                                  ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) AS distance,
                                  ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids,
                                  retailer_has_services.min_basket_value AS min_basket_value, retailer_has_services.service_fee AS service_fee")
                                   .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.service_fee, retailer_has_services.delivery_slot_skip_time, retailer_has_services.cutoff_time, retailer_has_services.delivery_type')
                                   .having("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) <= #{radius}")
                                   .order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})'))")
            else
              retailers = retailers.select("retailers.id, retailers.report_parent_id, retailers.company_name, retailers.company_name_ar, retailers.slug, retailers.is_opened, retailers.is_show_recipe, retailers.retailer_type, retailers.retailer_group_id,
                                  retailers.latitude, retailers.longitude, retailer_has_services.delivery_slot_skip_time AS delivery_slot_skip_hours, retailer_has_services.cutoff_time, retailer_has_services.delivery_type AS retailer_delivery_type,
                                  retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.location_id,
                                  retailers.photo1_file_name, retailers.photo1_content_type, retailers.photo1_file_size, retailers.photo1_updated_at,
                                  ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids,
                                  retailer_has_services.min_basket_value AS min_basket_value, retailer_has_services.service_fee AS service_fee, retailers.is_featured, retailers.with_stock_level")
                                   .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.service_fee, retailer_has_services.delivery_slot_skip_time, retailer_has_services.cutoff_time, retailer_has_services.delivery_type')
            end

            show_online_payment = true
            if retailers.length.positive?
              config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
                config = Setting.select(:id, :ios_version, :android_version, :web_version).first
              end
              show_online_payment = false if (request.headers['User-Agent'].include?('ElGrocerShopper') and config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
            end
            category_slot_wise = (request.headers['User-Agent'].include?('ElGrocerShopper') and (request.headers['App-Version'].to_s.gsub('.', '').to_i) > 6592552) || (request.headers['App-Version'].to_s.gsub('.', '').to_i > 74162306) || false
            present retailers, with: API::V1::Retailers::Entities::CncRetailerEntity, show_online_payment: show_online_payment, category_slot_wise: category_slot_wise
          end
        end
      end
    end
  end
end
