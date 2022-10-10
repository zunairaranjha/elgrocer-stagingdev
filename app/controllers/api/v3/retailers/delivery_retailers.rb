# frozen_string_literal: true

module API
  module V3
    module Retailers
      class DeliveryRetailers < Grape::API
        version 'v3', using: :path
        format :json

        helpers do
          params :list_of_delivery_retailers_param do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
            optional :all_type, type: Boolean, desc: 'To get all stores in store types ', documentation: { example: true }
          end

          def ret_store_types(all_type, retailers, retailer_ids)
            if all_type && retailers.length.positive?
              StoreType.joins('LEFT JOIN retailer_store_types ON retailer_store_types.store_type_id = store_types.id').where("retailer_store_types.retailer_id in (#{retailer_ids.join(",")}) or store_types.id = 0").distinct.order(:priority)
            else
              StoreType.joins(:retailer_store_types).where(retailer_store_types: { retailer_id: retailer_ids }).distinct.order(:priority)
            end
          end
        end

        resource :retailers do
          desc 'List of Delivery Retailers.'

          params do
            use :list_of_delivery_retailers_param
          end

          get '/delivery' do
            result = Rails.cache.fetch([params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).merge(api_version: 'v3/retailers/delivery').except(:shopper_id), __method__], expires_in: 15.minutes) do
              retailers = Retailer.eager_load_for_all_delivery_retailers
                                  .for_api_with_point(params[:longitude], params[:latitude], Time.now.seconds_since_midnight, Time.now.wday + 1)
              retailers = retailers.select("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) distance")
                                   .reorder('open_now desc').order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})'))", :priority, created_at: :desc)
              retailer_type_ids = []
              retailer_ids = retailers.map { |r| retailer_type_ids << r.retailer_type; r.id }
              retailers.delivery_ret_preload_payment_types(retailers)
              store_types = ret_store_types(params[:all_type], retailers, retailer_ids)
              retailer_types = RetailerType.where(id: retailer_type_ids).includes(:image)
              { retailers: retailers, store_types: store_types.to_a, retailer_types: retailer_types.to_a }
            end
            config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
              Setting.select(:id, :ios_version, :android_version, :web_version).first
            end
            if (request.headers['User-Agent'].include?('ElGrocerShopper') && config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
              show_online_payment = false
            else
              show_online_payment = true
            end
            present is_next: false
            present result[:store_types], with: API::V2::Retailers::Entities::StoreTypeEntity, colored_logo: true
            present result[:retailer_types], with: API::V3::Retailers::Entities::RetailerTypeEntity
            present result[:retailers], with: API::V3::Retailers::Entities::DeliveryRetailerEntity, except: %i[opening_time date_time_offset],
                    next_week_slots: true, show_online_payment: show_online_payment
          end
          #with Smiles Points
          desc 'List of Delivery Retailers With Smiles Points.'
          params do
            use :list_of_delivery_retailers_param
          end

          get '/delivery_stores' do
            result = Rails.cache.fetch([params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).merge(api_version: 'v3/retailers/delivery_stores').except(:shopper_id), __method__], expires_in: 15.minutes) do
              retailers = Retailer.eager_load_for_all_delivery_retailers
                                  .for_api_with_point(params[:longitude], params[:latitude], Time.now.seconds_since_midnight, Time.now.wday + 1)
              retailers = retailers.select("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) distance")
                                   .reorder('open_now desc').order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})'))", :priority, created_at: :desc)
              retailer_type_ids = []
              retailer_ids = retailers.map { |r| retailer_type_ids << r.retailer_type; r.id }
              store_types = ret_store_types(params[:all_type], retailers, retailer_ids)
              retailer_types = RetailerType.where(id: retailer_type_ids).includes(:image)
              { retailers: retailers, store_types: store_types.to_a, retailer_types: retailer_types.to_a }
            end
            config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
              Setting.select(:id, :ios_version, :android_version, :web_version).first
            end
            if (request.headers['User-Agent'].include?('ElGrocerShopper') && config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
              show_online_payment = false
            else
              show_online_payment = true
            end
            present is_next: false
            present result[:store_types], with: API::V2::Retailers::Entities::StoreTypeEntity, colored_logo: true
            present result[:retailer_types], with: API::V3::Retailers::Entities::RetailerTypeEntity
            present result[:retailers], with: API::V3::Retailers::Entities::DeliveryRetailerEntity, except: %i[opening_time date_time_offset available_payment_types],
                    next_week_slots: true, show_online_payment: show_online_payment
          end
        end
      end
    end
  end
end
