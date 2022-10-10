module API
  module V1
    module Retailers
      class ShowRetailer < Grape::API
        version 'v1', using: :path
        format :json

        resource :retailers do
          desc "Returns profile of a retailer.", entity: API::V2::Retailers::Entities::ShowRetailer
          params do
            requires :id, desc: 'Retailer ID'
            optional :latitude, type: Float, desc: 'Latitude Of Shopper', documentation: { example: 2.3456789 }
            optional :longitude, type: Float, desc: 'Longitude of Shopper', documentation: { example: 55.86567565 }
            optional :parent_id, type: Integer, desc: 'Parent Id for retailer', documentation: { example: 16 }
          end
          get '/show_retailer' do
            web = request.headers['Referer']
            if params[:id][/\p{L}/]
              retailers = Retailer.where(slug: params[:id])
            else
              retailers = Retailer.where("retailers.id = #{params[:id].to_i} or retailers.report_parent_id = #{params[:parent_id].to_i}")
            end
            # if retailer
            # retailers_cache = Rails.cache.fetch([params.merge(retailers_updated_at: "#{retailer.updated_at}").except(:ip_address),__method__]) do
            if params[:latitude] and params[:longitude]
              retailers = retailers.includes(:delivery_payment_types, :city, :next_available_slots, :retailer_group)
                                   .with_zone_containg_lonlat("POINT (#{params[:longitude]} #{params[:latitude]})")
                                   .where("retailers.is_active IS TRUE AND opening_time<>''")
            else
              retailers = retailers.includes(:delivery_payment_types, :city, :next_available_slots, :retailer_group)
                                   .where("retailers.is_active IS TRUE AND opening_time<>''")
                                   .joins("LEFT JOIN retailer_delivery_zones on retailer_delivery_zones.retailer_id = retailers.id")
                                   .joins("LEFT JOIN delivery_zones on delivery_zones.id = retailer_delivery_zones.delivery_zone_id")
            end
            retailers = retailers.joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
                                 .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
                                 .joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{Time.now.seconds_since_midnight} AND chour.day = #{Time.now.wday + 1}")
                                 .joins("LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id")
                                 .select("retailers.*, (array_agg(retailer_delivery_zones.min_basket_value))[1] min_basket_value, (array_agg(retailer_delivery_zones.delivery_fee))[1] delivery_fee, (array_agg(retailer_delivery_zones.rider_fee))[1] rider_fee, (array_agg(retailer_delivery_zones.id))[1] retailer_delivery_zones_id, (array_agg(delivery_zones.id))[1] delivery_zones_id,
                                  (array_agg(retailer_delivery_zones.delivery_type))[1] retailer_delivery_type, (is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close, ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids")
                                 .group('retailers.id')
                                 .distinct
            # .select("retailers.*,count(shops.is_promotional) promotional, max(retailer_delivery_zones.min_basket_value) min_basket_value, max(retailer_delivery_zones.delivery_fee) delivery_fee, max(retailer_delivery_zones.rider_fee) rider_fee, max(retailer_delivery_zones.id) retailer_delivery_zones_id, max(delivery_zones.id) delivery_zones_id, count(shopper_favourite_retailers.shopper_id) count_favorite,(is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close, ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids")
            # .joins("LEFT OUTER JOIN shops on shops.retailer_id = retailers.id and shops.is_promotional = 't' and shops.is_available = 't' and shops.is_published = 't'")
            # retailers.to_a
            # end
            retailers = retailers.select("retailers.seo_data") if web
            show_online_payment = true
            if retailers.length > 0
              # config = Setting.firstconfig = Rails.cache.fetch("retailers/show_online_payment/config", expires_in: 30.hours) do
              config = Rails.cache.fetch("retailers/show_online_payment/config", expires_in: 30.hours) do
                config = Setting.select(:id, :ios_version, :android_version, :web_version).first
              end
              show_online_payment = false if (request.headers['User-Agent'].include?("ElGrocerShopper") and config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub(".", "").to_i)) || config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub(".", "").to_i) || !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
            end
            category_slot_wise = (request.headers['User-Agent'].include?("ElGrocerShopper") and (request.headers['App-Version'].to_s.gsub(".", "").to_i) > 6592552) || (request.headers['App-Version'].to_s.gsub(".", "").to_i > 74162306) || false
            present retailers, with: API::V3::Retailers::Entities::ShowRetailer, show_online_payment: show_online_payment, web: web, category_slot_wise: category_slot_wise
            # else
            #   error!({error_code: 403, error_message: "Retailer does not exist"},403)
            # end
          end
        end
      end
    end
  end
end