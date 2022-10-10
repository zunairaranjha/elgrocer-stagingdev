# frozen_string_literal: true

module API
  module V2
    module Retailers
      class DeliveryRetailers < Grape::API
        version 'v2', using: :path
        format :json

        resource :retailers do
          desc 'List of Delivery Retailers.'

          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
            optional :all_type, type: Boolean, desc: 'To get all stores in store types ', documentation: { example: true }
          end

          get '/delivery' do
            result = Rails.cache.fetch([params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).except(:shopper_id), __method__], expires_in: 15.minutes) do
              retailers = Retailer.includes(:delivery_payment_types, :city, :next_slot_delivery, :retailer_group)
                                  .with_zone_containg_lonlat("POINT (#{params[:longitude]} #{params[:latitude]})")
                                  .where("retailers.is_active IS TRUE AND opening_time<>''")
                                  .joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
                                  .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
                                  .joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{Time.now.seconds_since_midnight} AND chour.day = #{Time.now.wday + 1}")
                                  .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                  .distinct
              retailers = retailers.select("retailers.*, ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) distance,
                                    (array_agg(retailer_delivery_zones.min_basket_value))[1] min_basket_value, (array_agg(retailer_delivery_zones.delivery_fee))[1] delivery_fee, (array_agg(retailer_delivery_zones.rider_fee))[1] rider_fee, (array_agg(retailer_delivery_zones.id))[1] retailer_delivery_zones_id, (array_agg(delivery_zones.id))[1] delivery_zones_id,
                                    (array_agg(retailer_delivery_zones.delivery_type))[1] retailer_delivery_type, (is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close, ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids")
                                   .group('retailers.id')
                                   .reorder('open_now desc').order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})'))", :priority, created_at: :desc)
              if params[:all_type] && retailers.length.positive?
                store_types = StoreType.joins('LEFT JOIN retailer_store_types ON retailer_store_types.store_type_id = store_types.id').where("retailer_store_types.retailer_id in (#{retailers.map { |ret| ret.id }.join(",")}) or store_types.id = 0").distinct.order(:priority)
              else
                store_types = StoreType.joins(:retailer_store_types).where(retailer_store_types: { retailer_id: retailers.map { |ret| ret.id } }).distinct.order(:priority)
              end
              result = { retailers: retailers, store_types: store_types.to_a }
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
            present result[:store_types], with: API::V2::Retailers::Entities::StoreTypeEntity
            present result[:retailers], with: API::V2::Retailers::Entities::DeliveryRetailerEntity, except: %i[opening_time date_time_offset],
                                        next_week_slots: true, show_online_payment: show_online_payment
          end
        end
      end
    end
  end
end
