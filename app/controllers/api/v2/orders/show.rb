# frozen_string_literal: true

module API
  module V2
    module Orders
      class Show < Grape::API
        # include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :orders do
          desc 'Find order by order id.', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order id', documentation: { example: '7894900011593' }
            optional :version, type: Integer, desc: 'Info for Version Number', documentation: { example: 1 }
          end

          get '/show' do
            app_version = request.headers['App-Version'].to_s.split('.').first.to_i
            order = Order.select(:id, :retailer_id).find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            Product.retailer_of_product = order&.retailer_id
            order = Order.where(id: params[:order_id])
            order = order.includes(:credit_card, :delivery_slot, { promotion_code_realization: :promotion_code })
            order = order.includes({ order_positions_views: [:product, { order_subs_view: [
                                     :shop_promotion, { substituting_product: %i[
                                       brand categories subcategories retailer_shops] }] }] })
            order = order.includes(:collector_detail, :pickup_loc, vehicle_detail: %i[color vehicle_model])
            for_retailer = app_version.positive? && app_version < 5
            order = order.includes({ analytics: :event }) if for_retailer
            present order.first, with: API::V2::Orders::Entities::ShowOrderEntity, retailer: for_retailer
          end
        end
      end
    end
  end
end
