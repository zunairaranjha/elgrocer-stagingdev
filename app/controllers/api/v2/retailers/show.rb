# frozen_string_literal: true

module API
  module V2
    module Retailers
      # This will return single retailer
      class Show < Grape::API
        version 'v2', using: :path
        format :json

        resource :retailers do
          desc 'Returns profile of a retailer.'
          params do
            requires :id, desc: 'Retailer ID'
            optional :latitude, type: Float, desc: 'Latitude Of Shopper', documentation: { example: 2.3456789 }
            optional :longitude, type: Float, desc: 'Longitude of Shopper', documentation: { example: 55.86567565 }
            optional :parent_id, type: Integer, desc: 'Parent Id for retailer', documentation: { example: 16 }
          end
          get '/delivery/show' do
            web = request.headers['Referer']
            retailers = fetch_retailer.eager_load_for_all_delivery_retailers
            retailers = ret_delivery_point(retailers, params[:latitude], params[:longitude])
            retailers = retailers.select('retailers.seo_data') if web
            retailers.delivery_ret_preload_payment_types(retailers)
            API::V2::Retailers::Entities::ShowEntity.represent retailers[0], root: false, show_online_payment: show_online_payment(retailers.length),
                               web: web, category_slot_wise: category_slot_wise
          end

          get '/delivery_store/show' do
            web = request.headers['Referer']
            retailers = fetch_retailer.eager_load_for_all_delivery_retailers
            retailers = ret_delivery_point(retailers, params[:latitude], params[:longitude])
            retailers = retailers.select('retailers.seo_data') if web
            API::V2::Retailers::Entities::ShowEntity.represent retailers[0], root: false, show_online_payment: show_online_payment(retailers.length),
                                                               web: web, category_slot_wise: category_slot_wise, except: %i[available_payment_types]
          end

          get '/click_and_collect/show' do
            # web = request.headers['Referer']
            retailers = fetch_retailer.eager_load_for_all_cc_retailers
                                      .joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                      .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                      .distinct
            retailers = ret_cc_point(retailers, params[:latitude], params[:longitude])
            retailers.cc_ret_preload_payment_types(retailers)
            API::V2::Retailers::Entities::CncRetailerEntity.represent retailers[0], root: false, show_online_payment: show_online_payment(retailers.length),
                                                                                 category_slot_wise: category_slot_wise
          end

          get '/click_and_collect_store/show' do
            # web = request.headers['Referer']
            retailers = fetch_retailer.eager_load_for_all_cc_retailers
                                      .joins(:click_and_collect_service).where(retailer_has_services: { is_active: true })
                                      .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
                                      .distinct
            retailers = ret_cc_point(retailers, params[:latitude], params[:longitude])
            API::V2::Retailers::Entities::CncRetailerEntity.represent retailers[0], root: false, show_online_payment: show_online_payment(retailers.length),
                                                                      category_slot_wise: category_slot_wise, except: %i[available_payment_types]
          end
        end

        helpers do
          def fetch_retailer
            error!(CustomErrors.instance.params_missing, 421) unless params[:id].present?
            if params[:id][/\p{L}/]
              Retailer.where(slug: params[:id])
            else
              Retailer.where("retailers.id = #{params[:id].to_i} or retailers.report_parent_id = #{params[:parent_id].to_i}")
            end
          end

          def show_online_payment(retailers_length)
            show_online_payment = true
            if retailers_length.positive?
              config = Rails.cache.fetch('retailers/show_online_payment/config', expires_in: 30.hours) do
                Setting.select(:id, :ios_version, :android_version, :web_version).first
              end
              if (request.headers['User-Agent'].include?('ElGrocerShopper') &&
                config.ios_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i)) ||
                 config.android_version.to_s.split(',').map(&:to_i).include?(request.headers['App-Version'].to_s.gsub('.', '').to_i) ||
                 !request.headers['Origin'].to_s.downcase.match(Regexp.union(config.web_version.to_s.split(','))).nil?
                show_online_payment = false
              end
            end
            show_online_payment
          end

          def category_slot_wise
            (request.headers['User-Agent'].include?('ElGrocerShopper') &&
              (request.headers['App-Version'].to_s.gsub('.', '').to_i) > 6592552) ||
              (request.headers['App-Version'].to_s.gsub('.', '').to_i > 74162306) || false
          end

          def ret_delivery_point(retailers, latitude, longitude)
            if latitude && longitude
              retailers.for_api_with_point(longitude, latitude, Time.now.seconds_since_midnight, Time.now.wday + 1)
            else
              retailers.for_api_without_point(Time.now.seconds_since_midnight, Time.now.wday + 1)
            end
          end

          def ret_cc_point(retailers, latitude, longitude)
            if latitude && longitude
              radius = RetailerService.find_by(id: 2)&.availability_radius
              retailers.for_cc_api_with_point(longitude, latitude, radius)
            else
              retailers.for_cc_api_without_point
            end
          end

        end
      end
    end
  end
end
