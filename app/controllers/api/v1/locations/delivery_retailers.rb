# frozen_string_literal: true

module API
  module V1
    module Locations
      class DeliveryRetailers < Grape::API
        version 'v1', using: :path
        format :json

        resource :locations do
          desc 'List of all retailers.'

          params do
            requires :location_id, desc: 'Shopper latitude', documentation: { example: '2 or al-barsha' }
          end

          get 'retailers/delivery' do
            web = request.headers['Referer']
            retailers = Rails.cache.fetch([params.except(:shopper_id), __method__], expires_in: 45.minutes) do
              retailers = Retailer.includes(:delivery_payment_types, :city, :next_slot_delivery, :retailer_group)
              retailers = retailers.joins(:retailer_has_locations)
              retailers = retailers.where('retailer_has_locations.location_id = ? ', Location.find(params[:location_id]))
              retailers = retailers.where("retailers.is_active IS TRUE AND opening_time<>''")
              retailers = retailers.joins('LEFT JOIN retailer_delivery_zones on retailer_delivery_zones.retailer_id = retailers.id')
              retailers = retailers.joins('LEFT JOIN delivery_zones on retailer_delivery_zones.delivery_zone_id = delivery_zones.id')
              retailers = retailers.joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
              retailers = retailers.joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
              retailers = retailers.joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{Time.now.seconds_since_midnight} AND chour.day = #{Time.now.wday + 1}")

              retailers = retailers.select("retailers.*, (array_agg(retailer_delivery_zones.min_basket_value))[1] min_basket_value, (array_agg(retailer_delivery_zones.delivery_fee))[1] delivery_fee, (array_agg(retailer_delivery_zones.rider_fee))[1] rider_fee, (array_agg(retailer_delivery_zones.id))[1] retailer_delivery_zones_id, (array_agg(delivery_zones.id))[1] delivery_zones_id,
                                    (array_agg(retailer_delivery_zones.delivery_type))[1] retailer_delivery_type, (is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close")
              retailers = retailers.group('retailers.id')
              retailers = retailers.reorder('open_now desc').order(:priority, created_at: :desc)
              retailers = retailers.distinct

              retailers = retailers.select('retailers.seo_data') if web

              retailers.to_a
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
            present retailers, with: API::V2::Retailers::Entities::DeliveryRetailerEntity, next_week_slots: true,
                               show_online_payment: show_online_payment, web: web
          end
        end
      end
    end
  end
end

