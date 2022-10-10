# frozen_string_literal: true

module API
  module V3
    module Retailers
      class Index < Grape::API
        version 'v3', using: :path
        format :json

        resource :retailers do
          desc "List of all retailers.", entity: API::V2::Retailers::Entities::IndexEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :latitude, type: Float, desc: 'Shopper latitude', documentation: { example: 2 }
            requires :longitude, type: Float, desc: 'Shopper longitude', documentation: { example: 2 }
            optional :shopper_id, type: Integer, desc: 'Shopper id, So it will return correct is_favourite', documentation: { example: 20 }
            optional :next_slot, type: Boolean, desc: 'Flag fro the latest build', documentation: { example: true }
          end
          get '/all' do
            result = Rails.cache.fetch([params.merge(longitude: params[:longitude].round(3)).merge(latitude: params[:latitude].round(3)).except(:shopper_id), __method__], expires_in: 24.hours) do
              retailers = Retailer.includes(:delivery_payment_types, :city, :next_available_slots, :retailer_group)
                                  .with_zone_containg_lonlat("POINT (#{params[:longitude]} #{params[:latitude]})")
                                  .where("retailers.is_active IS TRUE AND opening_time<>''")
                                  .joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
                                  .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
                                  .joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{Time.now.seconds_since_midnight} AND chour.day = #{Time.now.wday + 1}")
                                  .distinct
              retailers = retailers.select("retailers.*, ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})')) distance,
                                    (array_agg(retailer_delivery_zones.min_basket_value))[1] min_basket_value, (array_agg(retailer_delivery_zones.delivery_fee))[1] delivery_fee, (array_agg(retailer_delivery_zones.rider_fee))[1] rider_fee, (array_agg(retailer_delivery_zones.id))[1] retailer_delivery_zones_id, (array_agg(delivery_zones.id))[1] delivery_zones_id,
                                    (array_agg(retailer_delivery_zones.delivery_type))[1] retailer_delivery_type, (is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close")
                                   .group('retailers.id')
                                   .reorder('open_now desc').order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{params[:longitude]} #{params[:latitude]})'))", :priority, created_at: :desc)

              result = { is_next: false, retailers: retailers }
            end
            # config = Setting.first
            config = Rails.cache.fetch("retailers/show_online_payment/config", expires_in: 30.hours) do
              config = Setting.select(:id, :ios_version, :android_version, :web_version).first
            end
            if (request.headers['User-Agent'].include?("ElGrocerShopper") and config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub(".", "").to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub(".", "").to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
              show_online_payment = false
            else
              show_online_payment = true
            end
            present result, with: API::V3::Retailers::Entities::IndexEntity, next_slot: params[:next_slot], show_online_payment: show_online_payment
          end
        end
      end
    end
  end
end